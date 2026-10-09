library ieee;
use ieee.std_logic_1164.all;


--RO changes by propagation delay, so it never has fixed value.

entity RING_OSCILLATORS is
    generic(
        N_STAGES : integer := 5;
        WHICH_STAGE_RING : integer := 4
    );
    port(
        ENABLE : in std_logic;
        OUT_RING   : out std_logic
    );

end entity;

architecture RTL of RING_OSCILLATORS is

    type stage_t is array (0 to N_STAGES -1) of std_logic;
    signal N : stage_t;

    attribute KEEP : string;
    attribute DONT_TOUCH : string;

    attribute KEEP of N : signal is "TRUE";
    attribute DONT_TOUCH of N : signal is "TRUE";



begin
    --Inverters
    N(0) <= not (N(N_STAGES - 1) and ENABLE);

    gen_inverters : for I in 0 to (N_STAGES - 2) generate
    begin
        N(I+1) <= not N(I);
    end generate;

    OUT_RING <= N(WHICH_STAGE_RING);


end architecture;