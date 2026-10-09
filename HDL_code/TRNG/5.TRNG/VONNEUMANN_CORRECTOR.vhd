library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity VONNEUMANN_CORRECTOR is
    port(
        i_CLK  : in std_logic;
        i_RSTn : in std_logic;
        i_SAMPLED_BIT : in std_logic;
        i_SAMPLED_VALID : in std_logic;
        o_CORRECTED_DATA : out std_logic;
        o_CORRECTED_VALID : out std_logic
    );
end entity;

-- Von Neumann Corrector
-- Mapping used : 
-- 00 => discard
-- 11 => discard
-- 01 => 1
-- 10 => 0


architecture RTL of VONNEUMANN_CORRECTOR is
    signal FIRST_SAMPLE : std_logic;
    signal SAMPLE_CNT : unsigned(0 downto 0);
    signal COUPLE_BITS : std_logic_vector(1 downto 0);
begin
    GET_FIRST_SAMPLE_PROC : process(i_CLK)
    begin
        if rising_edge(i_CLK) then
            if i_RSTn = '0' then
                FIRST_SAMPLE <= '0';
                SAMPLE_CNT <= "0";
            else
                if i_SAMPLED_VALID = '1' then
                    FIRST_SAMPLE <= i_SAMPLED_BIT;
                    --automatically go back from 1 to 0
                    SAMPLE_CNT <= SAMPLE_CNT + 1;
                end if;
            end if;
        end if;
    end process;


COUPLE_BITS <= FIRST_SAMPLE & i_SAMPLED_BIT;

    CORRECTED_OUTPUT: process(i_CLK)
    begin
        if rising_edge(i_CLK) then
            if i_RSTn = '0' then
                o_CORRECTED_DATA <= '0';
                o_CORRECTED_VALID <= '0';
            else
                if ((i_SAMPLED_VALID = '1') and (SAMPLE_CNT = "1")) then
                    case COUPLE_BITS is 
                        when "00" =>
                            o_CORRECTED_VALID <= '0';
                        when "11" => 
                            o_CORRECTED_VALID <= '0';
                        when "01" =>
                            o_CORRECTED_VALID <= '1';
                            o_CORRECTED_DATA  <= '1';
                        when "10" =>
                            o_CORRECTED_VALID <= '1';
                            o_CORRECTED_DATA  <= '0';                            
                        when others =>
                            o_CORRECTED_VALID <= '0';    
                    end case;
                else
                    o_CORRECTED_VALID <= '0';
                end if;
            end if;
        end if;
    end process;

end architecture;