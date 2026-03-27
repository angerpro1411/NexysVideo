`timescale 1ns/1ps

module mram_async #(
    parameter ADDR_WIDTH = 22,
    parameter DATA_WIDTH = 16,
    parameter DEPTH = 1<<ADDR_WIDTH,

    parameter tAVQV = 35,
    parameter tGLQV = 15,
    parameter tEHQZ = 15,
    parameter tGHQZ = 10,
    parameter tWLQZ = 12,
    parameter tWHQX = 3,
    parameter tDVWH = 10
)
(
    input  logic E_n,
    input  logic G_n,
    input  logic W_n,
    input  logic UB_n,
    input  logic LB_n,

    input  logic [ADDR_WIDTH-1:0] ADDR,
    inout  wire  [DATA_WIDTH-1:0] DQ
);

logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

logic [DATA_WIDTH-1:0] dq_out;
logic bus_enable;

assign DQ = bus_enable ? dq_out : 'z;

/////////////////////////////////////////////////////
// WRITE
/////////////////////////////////////////////////////

always @(negedge W_n) begin
    if (!E_n) begin
        #(tDVWH);

        if (!UB_n)
            mem[ADDR][15:8] = DQ[15:8];

        if (!LB_n)
            mem[ADDR][7:0] = DQ[7:0];
    end
end

/////////////////////////////////////////////////////
// READ DATA PIPELINE
/////////////////////////////////////////////////////

always @(*) begin
    dq_out = mem[ADDR];

    if (UB_n) dq_out[15:8] = 'z;
    if (LB_n) dq_out[7:0]  = 'z;
end

/////////////////////////////////////////////////////
// BUS CONTROL (single controller)
/////////////////////////////////////////////////////

always @(*) begin

    bus_enable = 0;

    if (!E_n && W_n && !G_n)
        bus_enable = 1;

end

/////////////////////////////////////////////////////
// READ ACCESS DELAY
/////////////////////////////////////////////////////

assign #(tAVQV) dq_out = mem[ADDR];

endmodule
