module MRAM_COMMU_ver2 #(
    parameter int CLK_RATE_MHz = 100,

    // According to the datasheet:
    // Write cycle lasts minimum 45ns => 5 cycles
    // If W controls writing 25ns => 3 cycles
    parameter int WRITE_DELAY_CYCLE_NS = 45,
    parameter int WRITE_PULSE_MIN_NS   = 35,

    // READ CYCLE TIME 45ns => 5 cycles
    parameter int READ_CYCLE_TIME_NS = 55,

    // CHIP ENABLE TIME 45ns => 5 cycles
    parameter int CHIP_ENABLE_TIME_NS = 45,

    // Need 15ns for Next Read after Read, or Read-Write(Bus turnaround)
    parameter int READ_TIME_RECOVERY_NS = 35,

    // Need 12ns to the next write
    parameter int WRITE_TIME_RECOVERY_NS = 22,

    parameter int WRITE_HOLD_CYCLE = 2,
    parameter int DELAY_SET_UP_WINDOW_CYCLES = 2
)(
    input  logic         i_CLK,
    input  logic         i_RST_n,

    // REG0 : Control : RD/WRn, BLEN, BHEN, INTR_CLR
    // REG1 : STATUS  : ERR, Busy
    // REG2 : ADDRESS
    // REG3 : WR_DATA
    // REG4 : RD_DATA
    // REG5 : START

    input  logic         i_START_CMD,
    input  logic [31:0]  i_REG0,
    output logic [31:0]  o_REG1,
    input  logic [31:0]  i_REG2,
    input  logic [31:0]  i_REG3,
    output logic [31:0]  o_REG4,

    output logic         INTR,

    output logic         E_n,
    output logic         G_n,
    output logic         W_n,
    output logic [17:0]  ADDR,
    output logic         UB_n,
    output logic         LB_n,

    inout  wire [15:0]   DQ
);

    //----------------------------------------------------------------------
    // Functions
    //----------------------------------------------------------------------

    function automatic int NS_2_CYCLES (
        input int DURATION_NS,
        input int CLK_RATE_MHz
    );
        int CLK_PERIOD_NS;
        int CYCLES;
        begin
            CLK_PERIOD_NS = (1000 + CLK_RATE_MHz - 1) / CLK_RATE_MHz;
            CYCLES        = (DURATION_NS + CLK_PERIOD_NS - 1) / CLK_PERIOD_NS;
            return CYCLES;
        end
    endfunction

    function automatic int calc_write_rest2end;
        begin
            if (WRITE_DELAY_CYCLE > (WRITE_PULSE_MIN + WRITE_TIME_RECOVERY))
                calc_write_rest2end = WRITE_DELAY_CYCLE - WRITE_PULSE_MIN;
            else
                calc_write_rest2end = WRITE_TIME_RECOVERY;
        end
    endfunction

    //----------------------------------------------------------------------
    // Component Declaration
    //----------------------------------------------------------------------

    typedef enum logic [3:0] {
        IDLE,
        SET_UP,
        READ_SETUP,
        READ_ACCESS,
        READ_CAPTURE,
        READ_RECOVERY,
        WRITE_D_SETUP,
        WRITE_ASSERT,
        WRITE_HOLD,
        WRITE_RECOVERY
    } state_t;

    state_t PRE_ST, NX_ST;

    //----------------------------------------------------------------------
    // Registers / Signals
    //----------------------------------------------------------------------

    logic PRE_En,NX_En;
    logic PRE_Gn,NX_Gn;
    logic PRE_Wn,NX_Wn;

    logic PRE_UB_EN, PRE_LB_EN;

    logic NX_UB_EN, NX_LB_EN;

    logic [17:0] ADDR_REG;
    logic [17:0] ADDR_NX;

    logic [15:0] WRITE_DATA_REG;
    logic [15:0] WRITE_DATA_NX;

    logic [7:0] PRE_CNT;
    logic [7:0] NX_CNT;

    logic [15:0] PRE_DREAD;
    logic [15:0] NX_DREAD;

    logic BUSY_BIT;

    logic [15:0] D_READ;


    //----------------------------------------------------------------------
    // Timing Constants
    //----------------------------------------------------------------------

    localparam int WRITE_DELAY_CYCLE =
        NS_2_CYCLES(WRITE_DELAY_CYCLE_NS, CLK_RATE_MHz);

    localparam int WRITE_PULSE_MIN =
        NS_2_CYCLES(WRITE_PULSE_MIN_NS, CLK_RATE_MHz);

    localparam int READ_CYCLE_TIME =
        NS_2_CYCLES(READ_CYCLE_TIME_NS, CLK_RATE_MHz);

    localparam int READ_TIME_RECOVERY =
        NS_2_CYCLES(READ_TIME_RECOVERY_NS, CLK_RATE_MHz);

    localparam int CHIP_ENABLE_TIME =
        NS_2_CYCLES(CHIP_ENABLE_TIME_NS, CLK_RATE_MHz);

    localparam int WRITE_TIME_RECOVERY =
        NS_2_CYCLES(WRITE_TIME_RECOVERY_NS, CLK_RATE_MHz);

    localparam int WRITE_REST2END_CYCLE =
        calc_write_rest2end();

    //----------------------------------------------------------------------
    // Interrupt Register
    //----------------------------------------------------------------------

    logic INTR_REG;

    //----------------------------------------------------------------------
    // Output Assignments
    //----------------------------------------------------------------------

    assign UB_n  = PRE_UB_EN;
    assign LB_n  = PRE_LB_EN;

    assign E_n   = PRE_En;
    assign G_n   = PRE_Gn;
    assign W_n   = PRE_Wn;

    assign ADDR  = ADDR_REG;

    assign o_REG4 = {16'h0000, PRE_DREAD};

    assign o_REG1 = {
        29'd0,
        INTR_REG,
        1'b0,
        BUSY_BIT
    };

    assign INTR = INTR_REG;

    //----------------------------------------------------------------------
    // DQ Direction Control
    //----------------------------------------------------------------------

    assign DQ_OE =
        (PRE_ST == WRITE_D_SETUP) ||
        (PRE_ST == WRITE_ASSERT)  ||
        (PRE_ST == WRITE_HOLD);

    assign DQ_O = WRITE_DATA_REG;

    assign NOT_DQ_OE = ~DQ_OE;

    //----------------------------------------------------------------------
    // IOBUF Generate
    //----------------------------------------------------------------------

    genvar I;

    generate
        for (I = 0; I < 16; I++) begin : DQ_IOBUF_GEN

            IOBUF_WRAPPER IOBUF_inst (
                .I  (DQ_O[I]),
                .O  (DQ_IN[I]),
                .T  (NOT_DQ_OE),
                .IO (DQ[I])
            );

        end 
    endgenerate   


    always_ff @(posedge i_CLK) begin
    if (!i_RST_n)
        BUSY_BIT <= 1'b0;
    else
        BUSY_BIT <= (PRE_ST != IDLE);
    end


    //----------------------------------------------------------------------
    // INTR_PROC
    //----------------------------------------------------------------------

    always_ff @(posedge i_CLK) begin
        if (!i_RST_n) begin
            INTR_REG <= 1'b0;
        end
        else begin
            if (i_REG0[BIT_CLR_INTR]) begin
                INTR_REG <= 1'b0;
            end
            else if ((PRE_ST == WRITE_HOLD) ||
                     (PRE_ST == READ_CAPTURE)) begin
                INTR_REG <= 1'b1;
            end
        end
    end


    //----------------------------------------------------------------------
    // STATE_MACHINE
    //----------------------------------------------------------------------

    always_ff @(posedge i_CLK) begin
        if (!i_RST_n) begin

            PRE_ST <= IDLE;

            PRE_En <= 1'b1;
            PRE_Gn <= 1'b1;
            PRE_Wn <= 1'b1;

            PRE_UB_EN <= 1'b1;
            PRE_LB_EN <= 1'b1;

            ADDR_REG <= '0;

            WRITE_DATA_REG <= '0;

            PRE_CNT <= '0;

            PRE_DREAD <= '0;

        end
        else begin

            PRE_ST <= NX_ST;

            PRE_En <= NX_En;
            PRE_Gn <= NX_Gn;
            PRE_Wn <= NX_Wn;

            PRE_UB_EN <= NX_UB_EN;
            PRE_LB_EN <= NX_LB_EN;

            ADDR_REG <= ADDR_NX;

            WRITE_DATA_REG <= WRITE_DATA_NX;

            PRE_CNT <= NX_CNT;

            PRE_DREAD <= NX_DREAD;

        end
    end 


        //----------------------------------------------------------------------
    // NEXT_STATE
    //----------------------------------------------------------------------

    always_comb begin

        NX_ST = PRE_ST;

        NX_En = PRE_En;
        NX_Gn = PRE_Gn;
        NX_Wn = PRE_Wn;

        NX_UB_EN = PRE_UB_EN;
        NX_LB_EN = PRE_LB_EN;

        ADDR_NX = ADDR_REG;

        WRITE_DATA_NX = WRITE_DATA_REG;

        NX_CNT = PRE_CNT;

        NX_DREAD = PRE_DREAD;

        unique case (PRE_ST)   
            SET_UP: begin

                NX_CNT = '0;

                if (i_REG0[BIT_RD_WRn]) begin
                    NX_ST = READ_SETUP;
                end
                else begin
                    NX_ST = WRITE_D_SETUP;
                end

                if (i_REG0[BIT_LB]) begin
                    NX_LB_EN = 1'b0;
                end

                if (i_REG0[BIT_UB]) begin
                    NX_UB_EN = 1'b0;
                end

            end
            READ_SETUP: begin

                NX_En = 1'b1;
                NX_Wn = 1'b1;
                NX_Gn = 1'b1;

                NX_CNT = PRE_CNT + 8'd1;

                if (PRE_CNT == (DELAY_SET_UP_WINDOW_CYCLES - 1)) begin

                    NX_CNT = '0;

                    NX_ST = READ_ACCESS;

                    NX_En = 1'b0;

                end

            end
            READ_ACCESS: begin

                NX_En = 1'b0;
                NX_Wn = 1'b1;
                NX_Gn = 1'b0;

                NX_CNT = PRE_CNT + 8'd1;

                if (PRE_CNT == (READ_CYCLE_TIME - 1)) begin

                    NX_CNT = '0;

                    NX_ST = READ_CAPTURE;

                end

            end

            READ_CAPTURE: begin

                NX_ST = READ_RECOVERY;

                NX_En = 1'b0;
                NX_Wn = 1'b1;
                NX_Gn = 1'b0;

                NX_CNT = '0;

                NX_DREAD = DQ_IN;

            end

            READ_RECOVERY: begin

                NX_En = 1'b1;
                NX_Wn = 1'b1;
                NX_Gn = 1'b1;

                NX_CNT = PRE_CNT + 8'd1;

                if (PRE_CNT == (READ_TIME_RECOVERY - 1)) begin

                    NX_CNT = '0;

                    NX_ST = IDLE;

                end

            end
            WRITE_D_SETUP: begin

                NX_En = 1'b1;
                NX_Wn = 1'b1;
                NX_Gn = 1'b1;

                NX_CNT = PRE_CNT + 8'd1;

                if (PRE_CNT == (DELAY_SET_UP_WINDOW_CYCLES - 1)) begin

                    NX_En = 1'b0;

                    NX_CNT = '0;

                    NX_ST = WRITE_ASSERT;

                end

            end
-            WRITE_ASSERT: begin

                NX_En = 1'b0;
                NX_Wn = 1'b0;
                NX_Gn = 1'b1;

                NX_CNT = PRE_CNT + 8'd1;

                if (PRE_CNT == (WRITE_PULSE_MIN - 1)) begin

                    NX_ST = WRITE_HOLD;

                    NX_CNT = '0;

                end

            end
            WRITE_HOLD: begin

                // There is no clear rule showing delay time
                // between WE and CE.
                // De-assert Wn first.

                NX_En = 1'b0;
                NX_Wn = 1'b1;
                NX_Gn = 1'b1;

                NX_CNT = PRE_CNT + 8'd1;

                if (PRE_CNT == (WRITE_HOLD_CYCLE - 1)) begin

                    NX_ST = WRITE_RECOVERY;

                    NX_CNT = '0;

                end

            end
            WRITE_RECOVERY: begin

                NX_CNT = PRE_CNT + 8'd1;

                NX_En = 1'b1;
                NX_Wn = 1'b1;
                NX_Gn = 1'b1;

                // Time delay either for write recovery
                // or minimum write cycle requirement.

                if (PRE_CNT == (WRITE_REST2END_CYCLE - 1)) begin

                    NX_ST = IDLE;

                    NX_CNT = '0;

                end

            end
            default: begin

                NX_ST = PRE_ST;

                NX_En = PRE_En;
                NX_Gn = PRE_Gn;
                NX_Wn = PRE_Wn;

                NX_UB_EN = PRE_UB_EN;
                NX_LB_EN = PRE_LB_EN;

                ADDR_NX = ADDR_REG;

                WRITE_DATA_NX = WRITE_DATA_REG;

                NX_CNT = PRE_CNT;

                NX_DREAD = PRE_DREAD;

            end

        endcase

    end


endmodule