module RAM_2PORT_ASYNC #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 8 
    ) (
    input logic WR_CLK,RD_CLK,
    input logic [ADDR_WIDTH-1:0]WR_ADDR,RD_ADDR,
    input logic WR,RD,
    input logic [DATA_WIDTH-1:0]WR_DATA,
    output logic [DATA_WIDTH-1:0]RD_DATA
);

    logic [DATA_WIDTH-1:0] RAM [0:2**ADDR_WIDTH-1];

    always_ff @(posedge WR_CLK)
    begin
        if (WR) 
            RAM[WR_ADDR] <= WR_DATA;
    end

    always_ff @(posedge RD_CLK)
    begin
        if (RD)
            RD_DATA <= RAM[RD_ADDR];
    end

endmodule