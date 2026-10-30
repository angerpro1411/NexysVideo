`timescale 1ns/100ps

module sim();
    localparam DATA_WIDTH = 8;
    localparam ADDR_WIDTH = 3;
     logic WR_CLK,RD_CLK;
     logic ARSTN;
     logic [DATA_WIDTH-1:0]WR_DATA;
     logic [DATA_WIDTH-1:0]RD_DATA;
     logic WR,RD;
     logic RD_DATA_VALID;
     logic FULL,EMPTY,ALMOST_FULL,ALMOST_EMPTY;


 FIFO_ASYNC #(
    .DATA_WIDTH(8),
    .ADDR_WIDTH(3)

 ) fifo_test(
    .WR_CLK(WR_CLK),
    .RD_CLK(RD_CLK),
    .ARSTN(ARSTN),
    .WR_DATA(WR_DATA),
    .RD_DATA(RD_DATA),
    .WR(WR),
    .RD(RD),
    .RD_DATA_VALID(RD_DATA_VALID),
    .FULL(FULL),
    .EMPTY(EMPTY),
    .ALMOST_FULL(ALMOST_FULL),
    .ALMOST_EMPTY(ALMOST_EMPTY)
);    
    //Wr_CLK
    always begin
        WR_CLK = 1;
        #5;
        WR_CLK = 0;
        #5;
    end

    //RD_CLK
    initial begin
        #3
        while(1)     begin
            RD_CLK = 1;
            #3300ps;
            RD_CLK = 0;
            #3300ps;
        end
    end

    //reset 
    initial begin
        ARSTN = 0;
        #7 
        ARSTN = 1;
    end

    task WR_CMD(
        input logic[DATA_WIDTH-1:0] d_i
    );
        @(posedge WR_CLK);
        WR_DATA = d_i;
        WR = 1;
        @(posedge WR_CLK);
        WR = 0;
    endtask

    task RD_CMD(
        output logic[DATA_WIDTH-1:0] d_o
    );
        @(posedge RD_CLK);
        RD = 1;
        @(posedge RD_CLK);
        RD = 0;
        @(posedge RD_DATA_VALID);
        d_o = RD_DATA;
    endtask


    logic[DATA_WIDTH-1:0] arr[0:9];
    logic[DATA_WIDTH-1:0] d_o ;
    //stimulus
    initial begin
        //Create a random array
        foreach(arr[i])
            arr[i] = $urandom;
        WR = 0;
        RD = 0;
        repeat(2)
            @(negedge WR_CLK);

        //write 10 times
        foreach(arr[i])
            WR_CMD(arr[i]);

        //Read and check
        
        for (int i=0;i<8;i++) begin
            RD_CMD(d_o);
            check_read_data: assert (d_o == arr[i])
                else $error("Assertion failed at index %0d",i);
        end

        small_test();

        //write 10 times
        foreach(arr[i])
            arr[i] = $urandom;
        foreach(arr[i])
            WR_CMD(arr[i]);
        for (int i=0;i<8;i++) begin
            RD_CMD(d_o);
            check_read_data: assert (d_o == arr[i])
                else $error("Assertion failed at index %0d",i);
        end

    end

    task small_test();
        WR_CMD(8'h55);
        WR_CMD(8'hFF);
        RD_CMD(d_o);
        check_read_data1: assert (d_o == 8'h55)
        else $error("Assertion failed");
        RD_CMD(d_o);
        check_read_data2: assert (d_o == 8'hFF)
        else $error("Assertion failed");        
    endtask

endmodule