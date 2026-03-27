
`timescale 1ns/100ps

module MRAM_MODELING
#(
    parameter DATA_WIDTH = 16,
    parameter ADDR_WIDTH = 18,

    /*
    ** Write/Read operation
    ** Timing address must keep for stable
    */
    parameter tAVAV = 45,

    /*
    ** Read operation
    ** Address cycle time max ns
    ** From the moment all read condition meets
    ** till we have new data
    */
    parameter tELQV = 45, 

    /*
    ** Write operation
    ** Write recovery time,
    ** Address and data must be stable after 
    ** all write conditions done 
    */
    parameter tWHAX = 12,     


    /*
    ** Write operation
    ** Write recovery time,
    ** setup time for data-in must be stable before 
    ** all write conditions done 
    */
    parameter tDVEH = 15, 

    /*
    ** Write operation
    ** Write recovery time,
    ** hold time for data-in must be stable after 
    ** all write conditions done 
    */
    parameter tWHDX = 0, 


    /*
    ** Read operation
    ** Output hold from address change, 
    ** Even address change but output still hells
    ** data from previous address.
    */    
    parameter tAXQX = 3,  //

    // -----------------------------------------------
    // READ timing (Table 16)
    parameter tAVQV = 45,   // Address to Data Valid (Read Cycle Time)     max 45ns
    parameter tGLQV = 25,   // G# Low to Data Valid (Output Enable Access) max 25ns
    parameter tBLQV = 25,   // UB#/LB# Low to Data Valid (Byte Enable)     max 25ns
    parameter tELQX =  3,   // E# Low to Output Active                     min  3ns
    parameter tGLQX =  0,   // G# Low to Output Active                     min  0ns
    parameter tBLQX =  0,   // UB#/LB# Low to Output Active                min  0ns
    parameter tEHQZ = 15,   // E# High to Output Hi-Z                      max 15ns
    parameter tGHQZ = 15,   // G# High to Output Hi-Z                      max 15ns
    parameter tBHQZ = 10,   // UB#/LB# High to Output Hi-Z                 max 10ns

    // WRITE timing (Table 13)
    parameter tAVWL =  0,   // Address Setup before W# Low                 min  0ns
    parameter tAVWH = 30,   // Address Valid to end of Write (G# Low)      min 30ns
                            // (use 28ns if G# is High during write)
    parameter tWLWH = 25,   // Write Pulse Width   ? WAS WRONG (35), NOW CORRECT
    parameter tDVWH = 15,   // Data Valid to end of Write                  min 15ns

    // BUS TURNAROUND timing (Table 15)
    parameter tWLQZ = 15,   // W# Low to Data Hi-Z                         max 15ns
    parameter tWHQX =  3    // W# High to Output Active                    min  3ns


)
(
    input logic E_n,
    input logic G_n,
    input logic W_n,
    input logic[ADDR_WIDTH-1:0] ADDR,
    input logic UB_n, //Upper byte
    input logic LB_n, //Lower byte
    inout logic[DATA_WIDTH-1:0] DQ
);

    //Using these logics to control delay
    logic UB_EN,LB_EN;


    localparam tREAD_DELAY = tGLQV; // = tBLQV     

    logic [DATA_WIDTH-1:0]d_out;

    //RAM
    logic [DATA_WIDTH-1:0] mem [0:(1<<ADDR_WIDTH)-1];

    // -----------------------------------------------
    // DQ output ? only assign drives true Hi-Z
    // -----------------------------------------------
    assign DQ[15:8] = UB_EN ? d_out[15:8] : 8'bz;
    assign DQ[7:0]  = LB_EN ? d_out[7:0]  : 8'bz;


    always @(*) begin : READ_OPERATION
        if (!E_n && W_n && !G_n)
            d_out = #(tREAD_DELAY) mem[ADDR];
        else 
            d_out = 'x;
    end

    // ----------------------------------------------------------
    // Priority: E_n > G_n > UB_n  (matches Table 4)
    // ----------------------------------------------------------
    always @(*) begin
        if (E_n)        #(tEHQZ) UB_EN = 1'b0; // Chip disabled ? Hi-Z after tEHQZ
        else if (G_n)   #(tGHQZ) UB_EN = 1'b0; // Output disabled ? Hi-Z after tGHQZ
        else if (UB_n)  #(tBHQZ) UB_EN = 1'b0; // Upper byte disabled ? Hi-Z after tBHQZ
        else if (!W_n)  #(tWLQZ) UB_EN = 1'b0; // Write mode ? bus turnaround, Hi-Z after tWLQZ
        else                     UB_EN = 1'b1; // All conditions met ? output active
    end

    // ----------------------------------------------------------
    // Priority: E_n > G_n > LB_n  (matches Table 4)
    // ----------------------------------------------------------
    always @(*) begin
        if (E_n)        #(tEHQZ) LB_EN = 1'b0;
        else if (G_n)   #(tGHQZ) LB_EN = 1'b0;
        else if (LB_n)  #(tBHQZ) LB_EN = 1'b0;
        else if (!W_n)  #(tWLQZ) LB_EN = 1'b0;
        else            LB_EN = 1'b1;
    end






    // For W control writing
    // Write pulse must keep min tWLEH = 25ns
    // Write cycle must last atleast 45ns = time to keep ADDR
    // Data set-up time tDVWH = 15ns
    // Address hold time is 12 ns

    time w_fall_time;
    logic [DATA_WIDTH-1:0] dq_at_wfall;
    logic [ADDR_WIDTH-1:0] addr_at_wfall;

    always @(negedge W_n) begin
        if (!E_n) begin
            w_fall_time = $time;
            addr_at_wfall = ADDR; 
        end
    end


    //Check all violtion before commit data to memory
    always @(posedge W_n) begin
        if (!E_n) begin

            //1. Check set-up time for data
            if (($time - w_fall_time) < tWLWH) begin
                $warning("WRITING: *** tWLWH VIOLATION - Pulse = %0dns min = %0dns, WRITE Denied @ %0t ns ***",
                            ($time - w_fall_time), tWLWH, $time);
            end
            else begin
                if (!UB_n) mem[ADDR][15:8] = DQ[15:8];
                if (!LB_n) mem[ADDR][7:0]  = DQ[7:0];
                $display ("WRITING: Write to address 0x%h Data=0x%h Lock UB = %b Lock LB = %b at %t ns",ADDR,DQ,UB_n,LB_n,$time);

                begin: ADDR_HOLDTIME_CHECK
                    #(tWHAX);
                    if (ADDR != addr_at_wfall)
                        $warning("WRITING: ***Hold time VIOLATION tWHAX: ADDR changed within %d ns @ %0t ns ",tWHAX,$time);
                end

            end
    
        end  
    end
  

    // Initialize memory
    initial begin
        UB_EN = 0;
        LB_EN = 0;
        d_out = 0;
        for(int i=0;i<(1<<ADDR_WIDTH);i++)
            mem[i] = 0;


        $display ("MRAM Ready \n");
    end 


endmodule
