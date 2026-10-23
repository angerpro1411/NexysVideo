`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/23/2026 10:16:28 AM
// Design Name: 
// Module Name: sim
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


module sim();
    
    logic clk100;
    logic rst;
    logic[3:0]led;
    
    always begin
        clk100 = 1;
        #5;
        clk100 = 0;
        #5;
    end
    
    initial begin
        rst = 1;
        #7;
        rst = 0;
    end

    
    
    
    top uut(
        .clk100(clk100),
        .rst(rst),
        .led(led)
    );
endmodule
