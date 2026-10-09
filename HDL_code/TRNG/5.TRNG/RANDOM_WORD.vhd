library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RANDOM_WORD is
    generic(
        WORD : integer := 32
    );
    port(
        i_CLK   : in std_logic;
        i_RSTn  : in std_logic;
        i_CORRECTED_DATA : in std_logic;
        i_CORRECTED_VALID : in std_logic;
        o_RANDOM_WORD    : out std_logic_vector(WORD-1 downto 0)      
    );
end entity;

architecture RTL of RANDOM_WORD is
    signal SHIFT_REG32 : std_logic_vector(WORD-1 downto 0);
    signal BIT_CNT_2_32 : unsigned(31 downto 0);
    signal o_RANDOM_VALID : std_logic;
begin
    GET_WORD : process(i_CLK)
    begin
        if rising_edge(i_CLK) then
            if i_RSTn = '0' then
                SHIFT_REG32 <= (others => '0');
                o_RANDOM_VALID <= '0';
                BIT_CNT_2_32 <= (others => '0');
            else
                o_RANDOM_VALID <= '0';
                if i_CORRECTED_VALID = '1' then
                    SHIFT_REG32 <= SHIFT_REG32(WORD-2 downto 0) & i_CORRECTED_DATA;
                    BIT_CNT_2_32 <= BIT_CNT_2_32 + 1;
                    if BIT_CNT_2_32 = WORD-1 then
                        BIT_CNT_2_32 <= (others => '0');
                        o_RANDOM_VALID <= '1';
                    end if;
                end if;
            end if;
        end if;
    end process;

    REG_OUTPUT : PROCESS(i_CLK)
    begin
        if rising_edge(i_CLK) then
            if i_RSTn = '0' then
                o_RANDOM_WORD <= (others => '0');
            else
                if o_RANDOM_VALID = '1' then
                    o_RANDOM_WORD <= SHIFT_REG32;
                end if;
            end if;
        end if;
    end process;

end architecture;
