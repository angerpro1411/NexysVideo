library ieee;
use ieee.std_logic_1164.all;

entity ENTROPY_SAMPLE is
    generic(
        SAMPLE_CYCLES : integer := 8
    );
    port(
        i_CLK  : in std_logic;
        i_RSTn : in std_logic;
        i_ENTROPY_RAW : in std_logic;
        o_SAMPLED_BIT : out std_logic;
        o_SAMPLED_VALID : out std_logic
    );
end entity;

architecture RTL of ENTROPY_SAMPLE is
    signal CNT_2_SAMPLE : natural range 0 to SAMPLE_CYCLES-1;
    signal FF1,FF2 : std_logic;
begin
    CNT_PROC : process(i_CLK)
    begin
        if rising_edge(i_CLK) then
            if i_RSTn = '0' then
                CNT_2_SAMPLE <= 0;
            else    
                CNT_2_SAMPLE <= CNT_2_SAMPLE + 1;
                if CNT_2_SAMPLE = SAMPLE_CYCLES - 1 then
                    CNT_2_SAMPLE <= 0;
                end if;
            end if;
        end if;
    end process;

    SYNC_NIZER : process(i_CLK)
    begin
        if rising_edge(i_CLK) then
            if i_RSTn = '0' then
                FF1 <= '0';
                FF2 <= '0';
                o_SAMPLED_VALID <= '0';
            else
                FF1 <= i_ENTROPY_RAW;
                FF2 <= FF1;
                o_SAMPLED_VALID <= '0';     
                if CNT_2_SAMPLE = SAMPLE_CYCLES - 1 then
                    o_SAMPLED_VALID <= '1';
                end if;
            end if;
        end if;
    end process;

    o_SAMPLED_BIT <= FF2;


end architecture;