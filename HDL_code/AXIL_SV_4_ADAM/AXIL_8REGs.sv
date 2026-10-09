`include "adam/macros.svh"
`include "axi/assign.svh"
`include "axi/typedef.svh"

module adam_axil_mram #(
    `ADAM_CFG_PARAMS,

    parameter MAX_TRANS = FAB_MAX_TRANS
) (
    ADAM_SEQ.Slave   seq,
    ADAM_PAUSE.Slave pause,

    AXI_LITE.Slave   axil,

    output logic irq,

    output logic        e_n,
    output logic        w_n,
    output logic        g_n,

    output logic [17:0] mram_addr,

    output logic        ub_n,
    output logic        lb_n,

    inout  wire [15:0] dq
);

    //------------------------------------------------------------------
    // AXI typedefs
    //------------------------------------------------------------------

    `AXI_LITE_TYPEDEF_AW_CHAN_T(aw_chan_t, ADDR_T);
    `AXI_LITE_TYPEDEF_W_CHAN_T (w_chan_t , DATA_T, STRB_T);
    `AXI_LITE_TYPEDEF_B_CHAN_T (b_chan_t);
    `AXI_LITE_TYPEDEF_AR_CHAN_T(ar_chan_t, ADDR_T);
    `AXI_LITE_TYPEDEF_R_CHAN_T (r_chan_t , DATA_T);

    aw_chan_t aw_chan;
    w_chan_t  w_chan;
    b_chan_t  b_chan;
    ar_chan_t ar_chan;
    r_chan_t  r_chan;

    `AXI_LITE_ASSIGN_TO_AW(aw_chan, axil);
    `AXI_LITE_ASSIGN_TO_W (w_chan , axil);
    `AXI_LITE_ASSIGN_FROM_B(axil , b_chan);
    `AXI_LITE_ASSIGN_TO_AR(ar_chan, axil);
    `AXI_LITE_ASSIGN_FROM_R(axil , r_chan);

    //------------------------------------------------------------------
    // AXI FSM
    //------------------------------------------------------------------

    typedef enum logic [1:0] {
        W_IDLE,
        W_ADDR,
        W_DATA,
        W_RESP
    } write_state_t;

    typedef enum logic [1:0] {
        R_IDLE,
        R_DATA
    } read_state_t;

    write_state_t write_state, write_state_next;
    read_state_t  read_state , read_state_next;

    ADDR_T awaddr_reg;
    ADDR_T araddr_reg;

    DATA_T wdata_axi_reg;
    STRB_T wstrb_reg;

    logic[31:0]regs[0:7];
    //------------------------------------------------------------------
    // IRQ
    //------------------------------------------------------------------

    // *************** User ports ****************** //
    logic START_CMD;
    logic [31:0] CTR_REG;
    logic [31:0] ADDR_REG;
    logic [31:0] WR_DATA_REG;
    logic [31:0] STT_REG;
    logic [31:0] RD_DATA_REG;
    // *************** End of User ports ****************** //

    //------------------------------------------------------------------
    // Controller
    //------------------------------------------------------------------

    adam_periph_mram_controller u_mram_controller (
        .i_CLK(seg.clk),
        .i_RST_n(!seq.rst),

        .i_START_CMD(START_CMD),
        .i_REG0(CTR_REG),
        .o_REG1(STT_REG),
        .i_REG2(ADDR_REG),
        .i_REG3(WR_DATA_REG),
        .o_REG4(RD_DATA_REG),
        

        .INTR(irq),

        .e_n        (e_n),
        .w_n        (w_n),
        .g_n        (g_n),

        .addr       (mram_addr),

        .ub_n       (ub_n),
        .lb_n       (lb_n),

        .dq         (dq)
    );

    //------------------------------------------------------------------
    // Valid addresses
    //------------------------------------------------------------------

    function logic addr_is_valid(input ADDR_T addr);

        case (addr[7:0])

            8'h00,
            8'h04,
            8'h08,
            8'h0C,
            8'h10:
                return 1'b1;

            default:
                return 1'b0;

        endcase

    endfunction

    //------------------------------------------------------------------
    // Sequential
    //------------------------------------------------------------------

    always_ff @(posedge seq.clk) begin

        if (seq.rst) begin

            write_state <= W_IDLE;
            read_state  <= R_IDLE;

            awaddr_reg  <= '0;
            araddr_reg  <= '0;

            wdata_axi_reg <= '0;
            wstrb_reg     <= '0;

        end
        else begin

            write_state <= write_state_next;
            read_state  <= read_state_next;

            if (axil.aw_valid && axil.aw_ready)
                awaddr_reg <= aw_chan.addr;

            if (axil.ar_valid && axil.ar_ready)
                araddr_reg <= ar_chan.addr;

            if (axil.w_valid && axil.w_ready) begin
                wdata_axi_reg <= w_chan.data;
                wstrb_reg     <= w_chan.strb;
            end


            //----------------------------------------------------------
            // Register writes
            //----------------------------------------------------------

            if (write_state == W_RESP &&
                addr_is_valid(awaddr_reg) &&
                wstrb_reg == '1) begin
                case (awaddr_reg[7:2])

                    6'h00: regs[0] <= wdata_axi_reg;
                    6'h01: regs[1] <= wdata_axi_reg;
                    6'h02: regs[2] <= wdata_axi_reg;
                    6'h03: regs[3] <= wdata_axi_reg;

                    6'h04: regs[4] <= wdata_axi_reg;
                    6'h05: begin
                        regs[5] <= wdata_axi_reg;
                        if (wdata_axi_reg[0])
                            START_CMD <= 1'b1;
                    end
                    6'h06: regs[6] <= wdata_axi_reg;
                    6'h07: regs[7] <= wdata_axi_reg;

                endcase
            end

        end

    end

    //------------------------------------------------------------------
    // Command pulses
    //------------------------------------------------------------------

    assign write_req =
        (write_state == W_RESP) &&
        addr_is_valid(awaddr_reg) &&
        (awaddr_reg[7:0] == 8'h00) &&
        wdata_axi_reg[0];

    assign read_req =
        (write_state == W_RESP) &&
        addr_is_valid(awaddr_reg) &&
        (awaddr_reg[7:0] == 8'h00) &&
        wdata_axi_reg[1];

    //------------------------------------------------------------------
    // Write FSM
    //------------------------------------------------------------------

    always_comb begin

        write_state_next = write_state;

        axil.aw_ready = 1'b0;
        axil.w_ready  = 1'b0;
        axil.b_valid  = 1'b0;

        b_chan.resp = axi_pkg::RESP_OKAY;

        case (write_state)

            W_IDLE: begin

                axil.aw_ready = 1'b1;
                axil.w_ready  = 1'b1;

                if (axil.aw_valid && axil.w_valid)
                    write_state_next = W_RESP;
                else if (axil.aw_valid)
                    write_state_next = W_DATA;
                else if (axil.w_valid)
                    write_state_next = W_ADDR;

            end

            W_ADDR: begin

                axil.aw_ready = 1'b1;

                if (axil.aw_valid)
                    write_state_next = W_RESP;

            end

            W_DATA: begin

                axil.w_ready = 1'b1;

                if (axil.w_valid)
                    write_state_next = W_RESP;

            end

            W_RESP: begin

                axil.b_valid = 1'b1;

                if (axil.b_ready)
                    write_state_next = W_IDLE;

            end

        endcase

    end

    //------------------------------------------------------------------
    // Read FSM
    //------------------------------------------------------------------

    always_comb begin

        read_state_next = read_state;

        axil.ar_ready = 1'b0;
        axil.r_valid  = 1'b0;

        r_chan.data = '0;
        r_chan.resp = axi_pkg::RESP_OKAY;

        case (read_state)

            R_IDLE: begin

                axil.ar_ready = 1'b1;

                if (axil.ar_valid)
                    read_state_next = R_DATA;

            end

            R_DATA: begin

                case (araddr_reg[7:2])

                    6'h00: r_chan.data = regs[0];
                    6'h01: r_chan.data = STT_REG;
                    6'h02: r_chan.data = regs[2];
                    6'h03: r_chan.data = regs[3];

                    6'h04: r_chan.data = RD_DATA_REG;
                    6'h05: r_chan.data = regs[5];
                    6'h06: r_chan.data = regs[6];
                    6'h07: r_chan.data = regs[7];

                    default:
                        r_chan.data = 32'hDEADBEEF;

                endcase

                axil.r_valid = 1'b1;

                if (axil.r_ready)
                    read_state_next = R_IDLE;

            end

        endcase

    end


        // User code
    assign CTR_REG = regs[0];
	assign ADDR_REG = regs[2];
	assign WR_DATA_REG = regs[3];


endmodule




// `timescale 1ns / 1ps
// //////////////////////////////////////////////////////////////////////////////////
// // Company: 
// // Engineer: 
// // 
// // Create Date: 06/16/2026 02:38:54 PM
// // Design Name: 
// // Module Name: AXI_LITE_SLAVE_SV
// // Project Name: 
// // Target Devices: 
// // Tool Versions: 
// // Description: 
// // 
// // Dependencies: 
// // 
// // Revision:
// // Revision 0.01 - File Created
// // Additional Comments:
// // 
// //////////////////////////////////////////////////////////////////////////////////


// `include "adam/macros.svh"
// `include "axi/assign.svh"
// `include "axi/typedef.svh"

// module adam_axil_mram #(

//     `ADAM_CFG_PARAMS,
//     parameter MAX_TRANS = FAB_MAX_TRANS,

//     //User parameter    
//     parameter int AXIL_ADDR_WIDTH = 32,
//     parameter int NUM_REGS        = 8,
//     parameter int ADDRLSB         = 2
// )(

//     ADAM_SEQ.Slave   seq,
//     ADAM_PAUSE.Slave pause,

//     AXI_LITE.Slave   axil,    
//     //output to mram
//     output logic irq,

//     output logic e_n,
//     output logic g_n,
//     output logic w_n,
//     output logic [17:0] mram_addr,
//     output logic ub_n,
//     output logic lb_n,
    
//     inout [15:0] dq
// );


//     // User channel -- write for instantiation
//     logic START_CMD;
//     logic [31:0] CTR_REG;
//     logic [31:0] ADDR_REG;
//     logic [31:0] WR_DATA_REG;
//     logic [31:0] STT_REG;
//     logic [31:0] RD_DATA_REG;

//     logic S_AXI_ACLK = seq.clk;
//     logic S_AXI_ARESETN = !seq.rst;

//     // -----------------------------
//     // Local parameters
//     // -----------------------------
//     localparam int STROBE_WIDTH = DATA_WIDTH/8;
//     localparam int NUM_ADDR_BITS = $clog2(NUM_REGS);

//     typedef logic [DATA_WIDTH-1:0] reg_t;
//     reg_t AXI_SLAVE_R [0:NUM_REGS-1];

//     // -----------------------------
//     // Internal registers
//     // -----------------------------
//     logic [AXIL_ADDR_WIDTH-1:0] awaddr_reg, araddr_reg;
//     logic [DATA_WIDTH-1:0] wdata_reg;
//     logic [STROBE_WIDTH-1:0] wstrb_reg;

//     logic aw_pending, w_pending, ar_pending;
//     logic RD_TRANSACTION_DONE;
//     logic write_enable;

//     // -----------------------------
//     // Write strobe function
//     // -----------------------------
//     function automatic logic [DATA_WIDTH-1:0] apply_w_strb(
//         input logic [DATA_WIDTH-1:0] old_data,
//         input logic [DATA_WIDTH-1:0] new_data,
//         input logic [STROBE_WIDTH-1:0] wstrb
//     );
//         logic [DATA_WIDTH-1:0] tmp;
//         int i;
//         begin
//             tmp = old_data;
//             for (i = 0; i < STROBE_WIDTH; i++) begin
//                 if (wstrb[i])
//                     tmp[8*i +: 8] = new_data[8*i +: 8];
//             end
//             return tmp;
//         end
//     endfunction

//     // -----------------------------
//     // Instantiation MRAM Controller
//     // -----------------------------
//     adam_periph_mram_controller mram(
//         .i_CLK(S_AXI_ACLK),
//         .i_RST_n(S_AXI_ARESETN),
//         .i_START_CMD(START_CMD),
//         .i_REG0(CTR_REG),
//         .o_REG1(STT_REG),
//         .i_REG2(ADDR_REG),
//         .i_REG3(WR_DATA_REG),
//         .o_REG4(RD_DATA_REG),
        

//         .INTR(irq),

//         .E_n(e_n),
//         .G_n(g_n),
//         .W_n(w_n),
//         .ADDR(mram_addr),
//         .UB_n(ub_n),
//         .LB_n(lb_n),
        
//         .DQ(dq)    
//     );


//     // -----------------------------
//     // Handshake logic
//     // -----------------------------

//     assign axil.b_resp = 2'b00;
//     assign axil.r_resp = 2'b00;

//     // -----------------------------
//     // AW channel
//     // -----------------------------
//     always_ff @(posedge S_AXI_ACLK) begin
//         if (!S_AXI_ARESETN) begin
//             axil.aw_ready <= 1'b1;
//             aw_pending    <= 1'b0;
//         end else begin
//             if (axil.aw_ready && axil.aw_valid) begin
//                 axil.aw_ready <= 1'b0;
//                 aw_pending    <= 1'b1;
//             end else if (aw_pending && w_pending) begin
//                 axil.aw_ready <= 1'b1;
//                 aw_pending    <= 1'b0;
//             end
//         end
//     end

//     always_ff @(posedge S_AXI_ACLK) begin
//         if (!S_AXI_ARESETN)
//             awaddr_reg <= '0;
//         else if (axil.aw_ready && axil.aw_valid)
//             awaddr_reg <= axil.aw_addr;
//     end

//     // -----------------------------
//     // W channel
//     // -----------------------------
//     always_ff @(posedge S_AXI_ACLK) begin
//         if (!S_AXI_ARESETN) begin
//             axil.w_ready <= 1'b1;
//             w_pending    <= 1'b0;
//         end else begin
//             if (axil.w_ready && axil.w_valid) begin
//                 axil.w_ready <= 1'b0;
//                 w_pending    <= 1'b1;
//             end else if (aw_pending && w_pending) begin
//                 axil.w_ready <= 1'b1;
//                 w_pending    <= 1'b0;
//             end
//         end
//     end

//     always_ff @(posedge S_AXI_ACLK) begin
//         if (!S_AXI_ARESETN) begin
//             wdata_reg <= '0;
//             wstrb_reg <= '0;
//         end else if (axil.w_ready && axil.w_valid) begin
//             wdata_reg <= axil.w_data;
//             wstrb_reg <= axil.w_strb;
//         end
//     end

//     // -----------------------------
//     // Write to registers
//     // -----------------------------
//     assign write_enable = aw_pending & w_pending;

//     always_ff @(posedge S_AXI_ACLK) begin
//         int addr;
//         int idx;
//         START_CMD <= 1'b0;
//         if (!S_AXI_ARESETN) begin
//             for (int i = 0; i < NUM_REGS; i++)
//                 AXI_SLAVE_R[i] <= '0;
//         end else begin
//             if (write_enable) begin
//                 addr = awaddr_reg[4:2];
//                 idx  = addr;
//                 if (idx < NUM_REGS) begin
//                     AXI_SLAVE_R[idx] <= apply_w_strb(
//                         AXI_SLAVE_R[idx],
//                         wdata_reg,
//                         wstrb_reg
//                     );
//                     if (idx == 5) begin
//                         if (wdata_reg[0]) 
//                             START_CMD <= 1'b1;
//                     end
//                 end
//             end
//         end
//     end

//     // -----------------------------
//     // B channel
//     // -----------------------------
//     always_ff @(posedge S_AXI_ACLK) begin
//         if (!S_AXI_ARESETN)
//             axil.b_valid <= 1'b0;
//         else if (write_enable)
//             axil.b_valid <= 1'b1;
//         else if (axil.b_valid && axil.b_ready)
//             axil.b_valid <= 1'b0;
//     end

//     // -----------------------------
//     // AR channel
//     // -----------------------------
//     always_ff @(posedge S_AXI_ACLK) begin
//         if (!S_AXI_ARESETN) begin
//             axil.ar_ready <= 1'b1;
//             ar_pending    <= 1'b0;
//         end else begin
//             if (axil.ar_ready && axil.ar_valid) begin
//                 axil.ar_ready <= 1'b0;
//                 ar_pending    <= 1'b1;
//             end else if (RD_TRANSACTION_DONE) begin
//                 axil.ar_ready <= 1'b1;
//                 ar_pending    <= 1'b0;
//             end
//         end
//     end

//     always_ff @(posedge S_AXI_ACLK) begin
//         if (!S_AXI_ARESETN)
//             araddr_reg <= '0;
//         else if (axil.ar_ready && axil.ar_valid)
//             araddr_reg <= axil.ar_addr;
//     end

    
//     assign RD_TRANSACTION_DONE = axil.r_valid & axil.r_ready;

//     // Read data valid
//     always_ff @(posedge S_AXI_ACLK) begin
//         if (!S_AXI_ARESETN) begin
//             axil.r_valid <= 1'b0;
//         end else begin
//             if (ar_pending) 
//                 axil.r_valid <= 1'b1;
//             else if (RD_TRANSACTION_DONE)
//                 axil.r_valid <= 1'b0;
//         end
//     end 


//     // -----------------------------
//     // Read data path
//     // -----------------------------
//     always_ff @(posedge S_AXI_ACLK) begin
//         int addr;
//         int idx;
//         if (!S_AXI_ARESETN) begin
//             axil.r_data <= '0;
//         end else begin
//             if (ar_pending && !axil.r_valid) begin
//                 addr = araddr_reg[4:2];
//                 idx  = addr;
//                 case (idx)
//                     0 : axil.r_data <= AXI_SLAVE_R[0];
//                     1 : axil.r_data <= STT_REG;
//                     2 : axil.r_data <= AXI_SLAVE_R[2];
//                     3 : axil.r_data <= AXI_SLAVE_R[3];
//                     4 : axil.r_data <= RD_DATA_REG;
//                     5 : axil.r_data <= AXI_SLAVE_R[5];
//                     6 : axil.r_data <= AXI_SLAVE_R[6];
//                     7 : axil.r_data <= AXI_SLAVE_R[7];
//               default :axil.r_data <= 32'hDEADDEAD;
//               endcase
//             end 
//         end
//     end

//     //USERs can write processes here
//     assign CTR_REG = AXI_SLAVE_R[0];
// 	assign ADDR_REG = AXI_SLAVE_R[2];
// 	assign WR_DATA_REG = AXI_SLAVE_R[3]; 


// endmodule