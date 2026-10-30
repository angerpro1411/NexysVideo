
//Sync wr/rd ram, so rd data one cycle delay
module FIFO_ASYNC#(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4

)(
    input logic WR_CLK,RD_CLK,
    input logic ARSTN,
    input logic [DATA_WIDTH-1:0]WR_DATA,
    output logic [DATA_WIDTH-1:0]RD_DATA,
    input logic WR,RD,
    output logic RD_DATA_VALID,
    output logic FULL,EMPTY,ALMOST_FULL,ALMOST_EMPTY
);

    localparam  DEPTH = 2**ADDR_WIDTH;
    localparam  NEAR_FULL_POINT = $ceil(DEPTH*0.85);
    localparam  NEAR_EMPTY_POINT = $ceil(DEPTH*0.15);

    //add one extra wrap bit for distiguish between full and empty
    logic [ADDR_WIDTH:0]WR_PTR,NX_WR_PTR,NX_RD_PTR,RD_PTR;
    logic [ADDR_WIDTH:0]NX_WR_PTR_GREY,NX_RD_PTR_GREY;

    logic [ADDR_WIDTH:0]WR_PTR_GREY,WR_PTR_GREY_UNDER_RD_CLK1,WR_PTR_GREY_UNDER_RD_CLK2;
    logic [ADDR_WIDTH:0]RD_PTR_GREY,RD_PTR_GREY_UNDER_WR_CLK1,RD_PTR_GREY_UNDER_WR_CLK2;



    RAM_2PORT_ASYNC #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) mem (
        .WR_CLK(WR_CLK),
        .RD_CLK(RD_CLK),
        .WR_ADDR(WR_PTR[ADDR_WIDTH-1:0]),
        .RD_ADDR(RD_PTR[ADDR_WIDTH-1:0]),
        .WR(SUCCESSFUL_WR),
        .RD(SUCCESSFUL_RD),
        .WR_DATA(WR_DATA),
        .RD_DATA(RD_DATA)
    );


    // always_ff @(posedge WR_CLK, negedge ARSTN)
    // begin
    //     if (!ARSTN) begin
    //         WR_PTR_GREY <= 0;
    //         WR_PTR_GREY_PLUS1 <= 0; 
    //     end
    //     else begin 
    //         WR_PTR_GREY <= BIN_2_GREY(WR_PTR);
    //         WR_PTR_GREY_PLUS1 <= BIN_2_GREY(WR_PTR+1);
    //     end
    // end

    always_ff @(posedge RD_CLK, negedge ARSTN)
    begin
        if (!ARSTN) begin
            WR_PTR_GREY_UNDER_RD_CLK1 <= 0;
            WR_PTR_GREY_UNDER_RD_CLK2 <= 0;
            // WR_PTR_PLUS1_GREY_UNDER_RD_CLK1 <= 0;
            // WR_PTR_PLUS1_GREY_UNDER_RD_CLK2 <= 0;
        end
        else begin
            WR_PTR_GREY_UNDER_RD_CLK1 <= WR_PTR_GREY;
            WR_PTR_GREY_UNDER_RD_CLK2 <= WR_PTR_GREY_UNDER_RD_CLK1;
            // WR_PTR_PLUS1_GREY_UNDER_RD_CLK1 <= WR_PTR_GREY_PLUS1;
            // WR_PTR_PLUS1_GREY_UNDER_RD_CLK2 <= WR_PTR_PLUS1_GREY_UNDER_RD_CLK1;
        end
    end


    // always_ff @(posedge RD_CLK, negedge ARSTN)
    // begin
    //     if (!ARSTN) begin
    //         RD_PTR_GREY <= 0;
    //         RD_PTR_GREY_PLUS1 <= 0;  
    //     end
    //     else begin 
    //         RD_PTR_GREY <= BIN_2_GREY(RD_PTR);
    //         RD_PTR_GREY_PLUS1 <= BIN_2_GREY(RD_PTR+1);
    //     end
    // end

    always_ff @(posedge WR_CLK, negedge ARSTN)
    begin
        if (!ARSTN) begin
            RD_PTR_GREY_UNDER_WR_CLK1 <= 0;
            RD_PTR_GREY_UNDER_WR_CLK2 <= 0;
            // RD_PTR_PLUS1_GREY_UNDER_WR_CLK1 <= 0;
            // RD_PTR_PLUS1_GREY_UNDER_WR_CLK2 <= 0;
        end
        else begin
            RD_PTR_GREY_UNDER_WR_CLK1 <= RD_PTR_GREY;
            RD_PTR_GREY_UNDER_WR_CLK2 <= RD_PTR_GREY_UNDER_WR_CLK1;
            // RD_PTR_PLUS1_GREY_UNDER_WR_CLK1 <= RD_PTR_GREY_PLUS1;
            // RD_PTR_PLUS1_GREY_UNDER_WR_CLK2 <= RD_PTR_PLUS1_GREY_UNDER_WR_CLK1;            
        end
    end

    // //Don't need to change to grey because of 1 bit length

    // logic SUCCESSFUL_RD,SUCCESSFUL_RD_UNDER_WR_CLK1,SUCCESSFUL_RD_UNDER_WR_CLK2;

    assign SUCCESSFUL_RD = (RD && !EMPTY);

    // always_ff @(posedge WR_CLK, negedge ARSTN)
    // begin
    //     if (!ARSTN) begin
    //         SUCCESSFUL_RD_UNDER_WR_CLK1 <= 0;
    //         SUCCESSFUL_RD_UNDER_WR_CLK2 <= 0;
    //     end
    //     else begin
    //         SUCCESSFUL_RD_UNDER_WR_CLK1 <= SUCCESSFUL_RD;
    //         SUCCESSFUL_RD_UNDER_WR_CLK2 <= SUCCESSFUL_RD_UNDER_WR_CLK1;
    //     end
    // end

    // //Don't need to change to grey because of 1 bit length

    // logic SUCCESSFUL_WR,SUCCESSFUL_WR_UNDER_RD_CLK1,SUCCESSFUL_WR_UNDER_RD_CLK2;

    assign SUCCESSFUL_WR = (WR && !FULL);

    // always_ff @(posedge RD_CLK, negedge ARSTN)
    // begin
    //     if (!ARSTN) begin
    //         SUCCESSFUL_WR_UNDER_RD_CLK1 <= 0;
    //         SUCCESSFUL_WR_UNDER_RD_CLK2 <= 0;
    //     end
    //     else begin
    //         SUCCESSFUL_WR_UNDER_RD_CLK1 <= SUCCESSFUL_WR;
    //         SUCCESSFUL_WR_UNDER_RD_CLK2 <= SUCCESSFUL_WR_UNDER_RD_CLK1;
    //     end
    // end

    // assign FULL_CONDITION = ((WR_PTR_GREY_PLUS1[ADDR_WIDTH-2:0] == RD_PTR_GREY_UNDER_WR_CLK2[ADDR_WIDTH-2:0])
    //                 && (WR_PTR_GREY_PLUS1[ADDR_WIDTH:ADDR_WIDTH-1] == ~RD_PTR_GREY_UNDER_WR_CLK2[ADDR_WIDTH:ADDR_WIDTH-1]));
    // assign NOT_FULL_CONDITION = !((WR_PTR_GREY[ADDR_WIDTH-2:0] == RD_PTR_GREY_UNDER_WR_CLK2[ADDR_WIDTH-2:0])
    //                 && (WR_PTR_GREY[ADDR_WIDTH:ADDR_WIDTH-1] == ~RD_PTR_GREY_UNDER_WR_CLK2[ADDR_WIDTH:ADDR_WIDTH-1]));

    assign NX_WR_PTR = WR_PTR + SUCCESSFUL_WR;

    assign WR_PTR_GREY = BIN_2_GREY(WR_PTR);
    assign NX_WR_PTR_GREY = BIN_2_GREY(NX_WR_PTR);

    assign FULL_CONDITION = ((NX_WR_PTR_GREY[ADDR_WIDTH-2:0] == RD_PTR_GREY_UNDER_WR_CLK2[ADDR_WIDTH-2:0])
                    && (NX_WR_PTR_GREY[ADDR_WIDTH:ADDR_WIDTH-1] == ~RD_PTR_GREY_UNDER_WR_CLK2[ADDR_WIDTH:ADDR_WIDTH-1]));
    assign NOT_FULL_CONDITION = !((WR_PTR_GREY[ADDR_WIDTH-2:0] == RD_PTR_GREY_UNDER_WR_CLK2[ADDR_WIDTH-2:0])
                    && (WR_PTR_GREY[ADDR_WIDTH:ADDR_WIDTH-1] == ~RD_PTR_GREY_UNDER_WR_CLK2[ADDR_WIDTH:ADDR_WIDTH-1]));



    //writing process
    always_ff @(posedge WR_CLK, negedge ARSTN)
    begin
        if (!ARSTN) begin
            WR_PTR <= 0;
            FULL <= 1'b0;
        end 
        else begin

            if (WR && !FULL) begin
                WR_PTR <= WR_PTR + 1;
                if (FULL_CONDITION) FULL <= 1'b1;
            end
            else if (NOT_FULL_CONDITION)
                FULL <= 1'b0;
        end
    end

    //almost full calculation process
    logic[ADDR_WIDTH:0] OCCUPANCY_UNDER_WR_CLK;
    
    assign OCCUPANCY_UNDER_WR_CLK = NX_WR_PTR - GREY_2_BIN(RD_PTR_GREY_UNDER_WR_CLK2);


    
    always_ff @(posedge WR_CLK, negedge ARSTN)
    begin
        if (!ARSTN) begin
            ALMOST_FULL <= 1'b0;
        end 
        else begin
            if (WR && !FULL) begin
                if (OCCUPANCY_UNDER_WR_CLK >= NEAR_FULL_POINT) ALMOST_FULL <= 1'b1;
            end
            else if (OCCUPANCY_UNDER_WR_CLK < NEAR_FULL_POINT)
                ALMOST_FULL <= 1'b0;
        end
    end


    assign NX_RD_PTR = RD_PTR + SUCCESSFUL_RD;

    assign RD_PTR_GREY = BIN_2_GREY(RD_PTR);
    assign NX_RD_PTR_GREY = BIN_2_GREY(NX_RD_PTR);

    assign EMPTY_CONDITION = (NX_RD_PTR_GREY == WR_PTR_GREY_UNDER_RD_CLK2);
    assign NOT_EMPTY_CONDITION = (RD_PTR_GREY != WR_PTR_GREY_UNDER_RD_CLK2);

    //Reading process
    always_ff @(posedge RD_CLK, negedge ARSTN)
    begin
        if (!ARSTN) begin
            RD_PTR <= 0;
            EMPTY <= 1'b1;
            RD_DATA_VALID <= 1'b0;
        end
        else begin
            RD_DATA_VALID <= 1'b0;
            if (SUCCESSFUL_RD) begin
                RD_PTR <= RD_PTR + 1;
                RD_DATA_VALID <= 1'b1;
                if (EMPTY_CONDITION) EMPTY <= 1'b1;
            end 
            else if (NOT_EMPTY_CONDITION)   
                EMPTY <= 1'b0;
        end 
    end


    //almost empty calculation process
    logic[ADDR_WIDTH:0] OCCUPANCY_UNDER_RD_CLK;
    
    assign OCCUPANCY_UNDER_RD_CLK = GREY_2_BIN(WR_PTR_GREY_UNDER_RD_CLK2) - NX_RD_PTR;

    always_ff @(posedge RD_CLK, negedge ARSTN)
    begin
        if (!ARSTN) begin
            ALMOST_EMPTY <= 1'b1;
        end 
        else begin
            if (SUCCESSFUL_RD) begin
                if (OCCUPANCY_UNDER_RD_CLK <= NEAR_EMPTY_POINT) ALMOST_EMPTY <= 1'b1;
            end
            else if (OCCUPANCY_UNDER_RD_CLK > NEAR_EMPTY_POINT)
                ALMOST_EMPTY <= 1'b0;
        end
    end


    function logic[ADDR_WIDTH:0] BIN_2_GREY(
        input logic[ADDR_WIDTH:0] i_var
    );
        BIN_2_GREY = i_var ^ {1'b0,i_var[ADDR_WIDTH:1]};
    endfunction


    function logic[ADDR_WIDTH:0] GREY_2_BIN(
        input logic[ADDR_WIDTH:0] i_var
    );
        GREY_2_BIN[ADDR_WIDTH] = i_var[ADDR_WIDTH];
        for(int i = ADDR_WIDTH-1;i>=0;i--) begin
            GREY_2_BIN[i] = GREY_2_BIN[i+1] ^ i_var[i];
        end
    endfunction
endmodule