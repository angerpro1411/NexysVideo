`timescale 1ns/100ps

module corrector_2_rand_word_tb();

    logic i_CLK,
    i_RSTn,
    i_SAMPLED_BIT,
    i_SAMPLED_VALID,
    o_CORRECTED_DATA, 
    o_CORRECTED_VALID;

    localparam integer WORD = 4;
    logic [WORD-1:0] o_RANDOM_WORD;

    VONNEUMANN_CORRECTOR uut1 (
        .i_CLK(i_CLK),
        .i_RSTn(i_RSTn),
        .i_SAMPLED_BIT(i_SAMPLED_BIT),
        .i_SAMPLED_VALID(i_SAMPLED_VALID),
        .o_CORRECTED_DATA(o_CORRECTED_DATA),
        .o_CORRECTED_VALID(o_CORRECTED_VALID)
    );

    RANDOM_WORD #(.WORD(WORD)) uut2 (
        .i_CLK(i_CLK),
        .i_RSTn(i_RSTn),
        .i_CORRECTED_DATA(o_CORRECTED_DATA),
        .i_CORRECTED_VALID(o_CORRECTED_VALID),
        .o_RANDOM_WORD(o_RANDOM_WORD)      
    );        


    always 
    begin
        i_CLK = 0;
        #5;
        i_CLK = 1;
        #5;
    end 

    initial begin
        i_RSTn = 0;
        #13;
        i_RSTn = 1;
    end

    initial begin
        @(negedge i_CLK);
        // i_SAMPLED_BIT = $urandom_range(0,1);
        // i_SAMPLED_VALID = $urandom_range(0,1);

        i_SAMPLED_BIT = 1;
        i_SAMPLED_VALID = 1;
        @(negedge i_CLK);
        i_SAMPLED_BIT = 1;
        i_SAMPLED_VALID = 1;
        @(negedge i_CLK); 

        i_SAMPLED_BIT = 0;
        i_SAMPLED_VALID = 1;
        @(negedge i_CLK);
        i_SAMPLED_BIT = 1;
        i_SAMPLED_VALID = 1;
        @(negedge i_CLK); 

        i_SAMPLED_BIT = 0;
        i_SAMPLED_VALID = 1;
        @(negedge i_CLK);
        i_SAMPLED_BIT = 0;
        i_SAMPLED_VALID = 1;
        @(negedge i_CLK);

        i_SAMPLED_BIT = 0;
        i_SAMPLED_VALID = 1;
        @(negedge i_CLK);
        i_SAMPLED_BIT = 1;
        i_SAMPLED_VALID = 1;
        @(negedge i_CLK); 

        i_SAMPLED_BIT = 1;
        i_SAMPLED_VALID = 1;
        @(negedge i_CLK);
        i_SAMPLED_BIT = 0;
        i_SAMPLED_VALID = 1;
        @(negedge i_CLK);

        i_SAMPLED_BIT = 0;
        i_SAMPLED_VALID = 1;
        @(negedge i_CLK);
        i_SAMPLED_BIT = 1;
        i_SAMPLED_VALID = 1;
        @(negedge i_CLK); 

        i_SAMPLED_BIT = 1;
        i_SAMPLED_VALID = 1;
        @(negedge i_CLK);
        i_SAMPLED_BIT = 0;
        i_SAMPLED_VALID = 1;
        @(negedge i_CLK);       

        i_SAMPLED_BIT = 0;
        i_SAMPLED_VALID = 1;
        @(negedge i_CLK);
        i_SAMPLED_BIT = 0;
        i_SAMPLED_VALID = 1;
        @(negedge i_CLK);

        i_SAMPLED_BIT = 0;
        i_SAMPLED_VALID = 1;
        @(negedge i_CLK);
        i_SAMPLED_BIT = 1;
        i_SAMPLED_VALID = 1;
        @(negedge i_CLK);

        i_SAMPLED_BIT = 1;
        i_SAMPLED_VALID = 1;
        @(negedge i_CLK);
        i_SAMPLED_BIT = 0;
        i_SAMPLED_VALID = 1;
        @(negedge i_CLK);  

        i_SAMPLED_BIT = 1;
        i_SAMPLED_VALID = 1;
        @(negedge i_CLK);
        i_SAMPLED_BIT = 0;
        i_SAMPLED_VALID = 1;
        @(negedge i_CLK);                            
    end

    


endmodule