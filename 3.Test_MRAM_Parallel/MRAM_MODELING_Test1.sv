`timescale 1ns/100ps

// =============================================================
// Simple Behavioral Model — Avalanche Technology AS3004316
// Significant timings only
// FOR SIMULATION ONLY
// =============================================================

module MRAM_MODELING #(
    parameter DATA_WIDTH = 16,
    parameter ADDR_WIDTH = 18,

    // READ — worst case access time
    parameter tAVQV = 45,   // Address → Data Valid
    parameter tELQV = 45,   // E# Low  → Data Valid
    parameter tGLQV = 25,   // G# Low  → Data Valid

    // READ — Hi-Z release
    parameter tEHQZ = 15,   // E# High     → Hi-Z
    parameter tGHQZ = 15,   // G# High     → Hi-Z
    parameter tBHQZ = 10,   // UB#/LB# High→ Hi-Z

    // WRITE — critical timings
    parameter tWLWH = 25,   // Write Pulse Width min
    parameter tWHAX = 12    // Address Hold after W# high
)(
    input  wire                   E_n,
    input  wire                   G_n,
    input  wire                   W_n,
    input  wire  [ADDR_WIDTH-1:0] ADDR,
    input  wire                   UB_n,
    input  wire                   LB_n,
    inout  wire  [DATA_WIDTH-1:0] DQ
);

    // Worst case read delay
    localparam tMAX01 = (tAVQV > tELQV)  ? tAVQV  : tELQV;
    localparam tREAD  = (tMAX01 > tGLQV) ? tMAX01 : tGLQV;

    // Memory
    reg [DATA_WIDTH-1:0] mem [0:(1<<ADDR_WIDTH)-1];
    reg [DATA_WIDTH-1:0] d_out;
    reg                  UB_EN, LB_EN;

    // DQ driven only via assign for correct Hi-Z
    assign DQ[15:8] = UB_EN ? d_out[15:8] : 8'bz;
    assign DQ[7:0]  = LB_EN ? d_out[7:0]  : 8'bz;

    // ----------------------------------------------------------
    // READ: data valid after tREAD
    // ----------------------------------------------------------
    always @(ADDR or E_n or G_n or W_n) begin
        if (!E_n && !G_n && W_n)
            d_out = #(tREAD) mem[ADDR];
    end

    // ----------------------------------------------------------
    // UB_EN: single block, priority E_n > G_n > UB_n > W_n
    // ----------------------------------------------------------
    always @(E_n or G_n or UB_n or W_n) begin
        if (E_n)        #(tEHQZ) UB_EN = 1'b0;
        else if (G_n)   #(tGHQZ) UB_EN = 1'b0;
        else if (UB_n)  #(tBHQZ) UB_EN = 1'b0;
        else if (!W_n)  UB_EN = 1'b0;  // write mode, no output
        else            UB_EN = 1'b1;
    end

    // ----------------------------------------------------------
    // LB_EN: single block, priority E_n > G_n > LB_n > W_n
    // ----------------------------------------------------------
    always @(E_n or G_n or LB_n or W_n) begin
        if (E_n)        #(tEHQZ) LB_EN = 1'b0;
        else if (G_n)   #(tGHQZ) LB_EN = 1'b0;
        else if (LB_n)  #(tBHQZ) LB_EN = 1'b0;
        else if (!W_n)  LB_EN = 1'b0;  // write mode, no output
        else            LB_EN = 1'b1;
    end

    // ----------------------------------------------------------
    // WRITE: latch on posedge W#
    // ----------------------------------------------------------
    time w_fall_time;
    always @(negedge W_n) w_fall_time = $time;

    always @(posedge W_n) begin
        if (!E_n) begin
            // tWLWH check: was W# low long enough?
            if (($time - w_fall_time) < tWLWH)
                $display("[MRAM] *** tWLWH VIOLATION: W# pulse=%0dns min=%0dns, WRITE IGNORED @ %0t ns ***",
                          ($time - w_fall_time), tWLWH, $time);
            else begin
                // Commit write
                if (!UB_n) mem[ADDR][15:8] = DQ[15:8];
                if (!LB_n) mem[ADDR][7:0]  = DQ[7:0];
                $display("[MRAM] WRITE addr=0x%h data=0x%h UB=%b LB=%b @ %0t ns",
                          ADDR, DQ, !UB_n, !LB_n, $time);

                // tWHAX check: address must hold 12ns after W# high
                begin : WHAX_CHECK
                    reg [ADDR_WIDTH-1:0] addr_capture;
                    addr_capture = ADDR;
                    #(tWHAX);
                    if (addr_capture !== ADDR)
                        $display("[MRAM] *** tWHAX VIOLATION: ADDR changed within %0dns of W# high @ %0t ns ***",
                                  tWHAX, $time);
                end
            end
        end
    end

    // ----------------------------------------------------------
    // Initialize
    // ----------------------------------------------------------
    integer i;
    initial begin
        UB_EN = 1'b0;
        LB_EN = 1'b0;
        d_out = '0;
        for (i = 0; i < (1<<ADDR_WIDTH); i = i+1)
            mem[i] = '0;
        $display("[MRAM] Ready: AS3004316 256Kx16 4Mb tREAD=%0dns tWLWH=%0dns tWHAX=%0dns",
                  tREAD, tWLWH, tWHAX);
    end

endmodule