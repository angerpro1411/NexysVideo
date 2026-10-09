library ieee;
use ieee.std_logic_1164.all;

entity ENTROPY_RAW is
    generic(
        NUMB_RO : natural := 4;
        MIN_RO_STAGES : natural := 5;
        OUTP_WHICH_STAGE : natural := 4;
    );
    port(
        ENABLE_RO   : in std_logic;
        o_ENTRO_RAW : out std_logic
    );

end entity;

architecture RTL of ENTROPY_RAW is

    component RING_OSCILLATORS is
        generic(
            N_STAGES : integer := 5;
            WHICH_STAGE_RING : integer := 4
        );
        port(
            ENABLE : in std_logic;
            OUT_RING   : out std_logic
        );
    end component;

    type RO_t is array (0 to NUMB_RO-1) of std_logic;
    signal RO : RO_t;

    function XOR_REDUCE(var: RO_t) return std_logic is
        variable result : std_logic := '0';
    begin
        for I in var'range loop
            result := result xor var(I);
        end loop;
        return result;
    end function;

    

begin

    gen_ro: for I in 0 to NUMB_RO-1 generate
    begin
        MY_RO : RING_OSCILLATORS
            generic map(
                N_STAGES => MIN_RO_STAGES + I*2,
                WHICH_STAGE_RING => OUTP_WHICH_STAGE  + I*2
            )
            port map(
                ENABLE => ENABLE_RO,
                OUT_RING => RO(I)
            );
    end generate;

    o_ENTRO_RAW <= XOR_REDUCE(RO);

end architecture;