`timescale 1ns/100ps

module TRNG #(
    parameter NUMB_RO = 4,
    parameter MIN_RO_STAGES = 5,
    parameter OUTP_WHICH_STAGE = 4,
    parameter SAMPLE_CYCLES = 8,
    parameter WORD_SIZE = 32
)
(
    input logic i_CLK,
    input logic i_RSTn,
    input logic ENABLE_RO,
    output logic [31:0] o_RANDOM_WORD
);

    logic ENTRO_RAW;
    logic SAMPLED_BIT,SAMPLED_VALID;
    logic CORRECTED_DATA,CORRECTED_VALID;


    ENTROPY_RAW 
    #(
        .NUMB_RO(NUMB_RO),
        .MIN_RO_STAGES(MIN_RO_STAGES),
        .OUTP_WHICH_STAGE(OUTP_WHICH_STAGE)
    )
    ENTROPY_RAW_INST (
        .ENABLE_RO(ENABLE_RO),
        .o_ENTRO_RAW(ENTRO_RAW)
    );


    ENTROPY_SAMPLE 
    #(
        .SAMPLE_CYCLES(SAMPLE_CYCLES)
    )
    ENTROPY_SAMPLE_INST(
        .i_CLK(i_CLK),
        .i_RSTn(i_RSTn),
        .i_ENTROPY_RAW(ENTRO_RAW),
        .o_SAMPLED_BIT(SAMPLED_BIT),
        .o_SAMPLED_VALID(SAMPLED_VALID)
    );

    VONNEUMANN_CORRECTOR VONNEUMANN_CORRECTOR_INST (
        .i_CLK(i_CLK),
        .i_RSTn(i_RSTn),
        .i_SAMPLED_BIT(SAMPLED_BIT),
        .i_SAMPLED_VALID(SAMPLED_VALID),
        .o_CORRECTED_DATA(CORRECTED_DATA),
        .o_CORRECTED_VALID(CORRECTED_VALID)
    );

    RANDOM_WORD #(.WORD(WORD_SIZE)) RANDOM_WORD_INST (
        .i_CLK(i_CLK),
        .i_RSTn(i_RSTn),
        .i_CORRECTED_DATA(CORRECTED_DATA),
        .i_CORRECTED_VALID(CORRECTED_VALID),
        .o_RANDOM_WORD(o_RANDOM_WORD)      
    );     


endmodule