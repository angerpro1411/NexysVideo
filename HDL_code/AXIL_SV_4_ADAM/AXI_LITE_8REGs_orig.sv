`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/16/2026 02:38:54 PM
// Design Name: 
// Module Name: AXI_LITE_SLAVE_SV
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns / 1ps

module AXI_LITE_SLAVE_SV #(
    parameter int DATA_WIDTH      = 32,
    parameter int AXIL_ADDR_WIDTH = 32,
    parameter int NUM_REGS        = 8,
    parameter int ADDRLSB         = 2
)(

    // User channel
    output logic o_START_CMD,
    output logic [31:0] o_CTR_REG,
    output logic [31:0] o_ADDR_REG,
    output logic [31:0] o_WR_DATA_REG,
    input logic [31:0] i_STT_REG,
    input logic [31:0] i_RD_DATA_REG,
    
    

    input  logic S_AXI_ACLK,
    input  logic S_AXI_ARESETN,

    // Write address channel
    input  logic [AXIL_ADDR_WIDTH-1:0] S_AXI_AWADDR,
    input  logic S_AXI_AWVALID,
    output logic S_AXI_AWREADY,

    // Write data channel
    input  logic [DATA_WIDTH-1:0] S_AXI_WDATA,
    input  logic [(DATA_WIDTH/8)-1:0] S_AXI_WSTRB,
    input  logic S_AXI_WVALID,
    output logic S_AXI_WREADY,

    // Write response
    input  logic S_AXI_BREADY,
    output logic S_AXI_BVALID,
    output logic [1:0] S_AXI_BRESP,

    // Read address channel
    input  logic [AXIL_ADDR_WIDTH-1:0] S_AXI_ARADDR,
    input  logic S_AXI_ARVALID,
    output logic S_AXI_ARREADY,

    // Read data channel
    output logic [DATA_WIDTH-1:0] S_AXI_RDATA,
    output logic [1:0] S_AXI_RRESP,
    output logic S_AXI_RVALID,
    input  logic S_AXI_RREADY
);

    // -----------------------------
    // Local parameters
    // -----------------------------
    localparam int STROBE_WIDTH = DATA_WIDTH/8;
    localparam int NUM_ADDR_BITS = $clog2(NUM_REGS);

    typedef logic [DATA_WIDTH-1:0] reg_t;
    reg_t AXI_SLAVE_R [0:NUM_REGS-1];

    // -----------------------------
    // Internal registers
    // -----------------------------
    logic [AXIL_ADDR_WIDTH-1:0] awaddr_reg, araddr_reg;
    logic [DATA_WIDTH-1:0] wdata_reg;
    logic [STROBE_WIDTH-1:0] wstrb_reg;

    logic aw_pending, w_pending, ar_pending;
    logic RD_TRANSACTION_DONE;
    logic write_enable;
    // -----------------------------
    // Write strobe function
    // -----------------------------
    function automatic logic [DATA_WIDTH-1:0] apply_w_strb(
        input logic [DATA_WIDTH-1:0] old_data,
        input logic [DATA_WIDTH-1:0] new_data,
        input logic [STROBE_WIDTH-1:0] wstrb
    );
        logic [DATA_WIDTH-1:0] tmp;
        int i;
        begin
            tmp = old_data;
            for (i = 0; i < STROBE_WIDTH; i++) begin
                if (wstrb[i])
                    tmp[8*i +: 8] = new_data[8*i +: 8];
            end
            return tmp;
        end
    endfunction

    // -----------------------------
    // Handshake logic
    // -----------------------------

    assign S_AXI_BRESP = 2'b00;
    assign S_AXI_RRESP = 2'b00;

    // -----------------------------
    // AW channel
    // -----------------------------
    always_ff @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) begin
            S_AXI_AWREADY <= 1'b1;
            aw_pending    <= 1'b0;
        end else begin
            if (S_AXI_AWREADY && S_AXI_AWVALID) begin
                S_AXI_AWREADY <= 1'b0;
                aw_pending    <= 1'b1;
            end else if (aw_pending && w_pending) begin
                S_AXI_AWREADY <= 1'b1;
                aw_pending    <= 1'b0;
            end
        end
    end

    always_ff @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN)
            awaddr_reg <= '0;
        else if (S_AXI_AWREADY && S_AXI_AWVALID)
            awaddr_reg <= S_AXI_AWADDR;
    end

    // -----------------------------
    // W channel
    // -----------------------------
    always_ff @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) begin
            S_AXI_WREADY <= 1'b1;
            w_pending    <= 1'b0;
        end else begin
            if (S_AXI_WREADY && S_AXI_WVALID) begin
                S_AXI_WREADY <= 1'b0;
                w_pending    <= 1'b1;
            end else if (aw_pending && w_pending) begin
                S_AXI_WREADY <= 1'b1;
                w_pending    <= 1'b0;
            end
        end
    end

    always_ff @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) begin
            wdata_reg <= '0;
            wstrb_reg <= '0;
        end else if (S_AXI_WREADY && S_AXI_WVALID) begin
            wdata_reg <= S_AXI_WDATA;
            wstrb_reg <= S_AXI_WSTRB;
        end
    end

    // -----------------------------
    // Write to registers
    // -----------------------------
    assign write_enable = aw_pending & w_pending;

    always_ff @(posedge S_AXI_ACLK) begin
        int addr;
        int idx;
        o_START_CMD <= 1'b0;
        if (!S_AXI_ARESETN) begin
            for (int i = 0; i < NUM_REGS; i++)
                AXI_SLAVE_R[i] <= '0;
        end else begin
            if (write_enable) begin
                addr = awaddr_reg[ADDRLSB + NUM_ADDR_BITS - 1 : ADDRLSB];
                idx  = addr;
                if (idx < NUM_REGS) begin
                    AXI_SLAVE_R[idx] <= apply_w_strb(
                        AXI_SLAVE_R[idx],
                        wdata_reg,
                        wstrb_reg
                    );
                    if (idx == 5) begin
                        if (wdata_reg[0]) 
                            o_START_CMD <= 1'b1;
                    end
                end
            end
        end
    end

    // -----------------------------
    // B channel
    // -----------------------------
    always_ff @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN)
            S_AXI_BVALID <= 1'b0;
        else if (write_enable)
            S_AXI_BVALID <= 1'b1;
        else if (S_AXI_BVALID && S_AXI_BREADY)
            S_AXI_BVALID <= 1'b0;
    end

    // -----------------------------
    // AR channel
    // -----------------------------
    always_ff @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) begin
            S_AXI_ARREADY <= 1'b1;
            ar_pending    <= 1'b0;
        end else begin
            if (S_AXI_ARREADY && S_AXI_ARVALID) begin
                S_AXI_ARREADY <= 1'b0;
                ar_pending    <= 1'b1;
            end else if (RD_TRANSACTION_DONE) begin
                S_AXI_ARREADY <= 1'b1;
                ar_pending    <= 1'b0;
            end
        end
    end

    always_ff @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN)
            araddr_reg <= '0;
        else if (S_AXI_ARREADY && S_AXI_ARVALID)
            araddr_reg <= S_AXI_ARADDR;
    end

    
    assign RD_TRANSACTION_DONE = S_AXI_RVALID & S_AXI_RREADY;

    // Read data valid
    always_ff @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) begin
            S_AXI_RVALID <= 1'b0;
        end else begin
            if (ar_pending) 
                S_AXI_RVALID <= 1'b1;
            else if (RD_TRANSACTION_DONE)
                S_AXI_RVALID <= 1'b0;
        end
    end 


    // -----------------------------
    // Read data path
    // -----------------------------
    always_ff @(posedge S_AXI_ACLK) begin
        int addr;
        int idx;
        if (!S_AXI_ARESETN) begin
            S_AXI_RDATA <= '0;
        end else begin
            if (ar_pending && !S_AXI_RVALID) begin
                addr = araddr_reg[ADDRLSB + NUM_ADDR_BITS - 1 : ADDRLSB];
                idx  = addr;
                case (idx)
                    0 : S_AXI_RDATA <= AXI_SLAVE_R[0];
                    1 : S_AXI_RDATA <= i_STT_REG;
                    2 : S_AXI_RDATA <= AXI_SLAVE_R[2];
                    3 : S_AXI_RDATA <= AXI_SLAVE_R[3];
                    4 : S_AXI_RDATA <= i_RD_DATA_REG;
                    5 : S_AXI_RDATA <= AXI_SLAVE_R[5];
                    6 : S_AXI_RDATA <= AXI_SLAVE_R[6];
                    7 : S_AXI_RDATA <= AXI_SLAVE_R[7];
              default :S_AXI_RDATA <= 32'hDEADDEAD;
              endcase
            end 
        end
    end

    //USERs can write processes here
    assign o_CTR_REG = AXI_SLAVE_R[0];
	assign o_ADDR_REG = AXI_SLAVE_R[2];
	assign o_WR_DATA_REG = AXI_SLAVE_R[3]; 


endmodule