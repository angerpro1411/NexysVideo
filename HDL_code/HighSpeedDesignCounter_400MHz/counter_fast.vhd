----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/21/2026 04:09:11 PM
-- Design Name: 
-- Module Name: counter_fast - RTL
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity counter_fast is
    generic(
        No_CHUNK : integer := 6;
        BIT_WIDTH : integer := 8
    );
    port(
        i_CLK : in std_logic;
        i_RST : in std_logic;
        LED   : out std_logic_vector(3 downto 0)
    );
end counter_fast;

architecture RTL of counter_fast is
    type CNT_t is array (0 to No_CHUNK-1) of unsigned(BIT_WIDTH-1 downto 0);
    signal CNT : CNT_t;
    
    signal CARRY : std_logic_vector(0 to No_CHUNK-2);
    signal ALLFF : std_logic_vector(1 to No_CHUNK-2);
    
    
    constant ALL_ONES : unsigned(BIT_WIDTH-1 downto 0) := (others => '1');
    constant ALMOST   : unsigned(BIT_WIDTH-1 downto 0) := ALL_ONES - 1;
    
    constant G_VIS : integer := 26;   -- lowest visible bit

    signal FULL : unsigned(No_CHUNK*BIT_WIDTH-1 downto 0);
    
begin

    
    CNT_PROCESS : process(i_CLK,i_RST)
    begin
        if i_RST = '1' then
            for i in 0 to No_CHUNK-1 loop
                CNT(i) <= (others => '0');
            end loop;
        elsif rising_edge(i_CLK) then
            CNT(0) <= CNT(0) + 1;
        
            for i in 1 to No_CHUNK-1 loop
                if CARRY(i-1) = '1' then
                    CNT(i) <= CNT(i) + 1;
                end if;
            end loop;
        end if;
    end process;    


    CARRY_MANAGE : process(i_CLK,i_RST)
    begin
        if i_RST = '1' then
                CARRY <= (others => '0');
        elsif rising_edge(i_CLK) then
            if CNT(0) = ALMOST then 
                CARRY(0) <= '1'; else CARRY(0) <= '0'; end if;
            for i in 1 to No_CHUNK-2 loop    
                if ALLFF(i) = '1' and CNT(0) = ALMOST then
                    CARRY(i) <= '1'; else CARRY(i) <= '0'; end if;
            end loop;
        end if;    
            
    end process;
    
    ALLFF_CONTROL : process(i_CLK,i_RST)
    begin
        if i_RST = '1' then
            ALLFF <= (others => '0');
        elsif rising_edge(i_CLK) then
            if CNT(1) = ALL_ONES then
                ALLFF(1) <= '1';
            else
                ALLFF(1) <= '0';
            end if;
            
            for i in 2 to No_CHUNK-2 loop
                if CNT(i) = ALL_ONES and ALLFF(i-1) = '1' then
                    ALLFF(i) <= '1'; 
                else 
                    ALLFF(i) <= '0';
                end if;
            end loop;
        end if;
            
    end process;

    GEN_FULL : for i in 0 to No_CHUNK-1 generate
        FULL((i+1)*BIT_WIDTH-1 downto i*BIT_WIDTH) <= CNT(i);
    end generate;
    
    LED(2 downto 0) <= std_logic_vector(FULL(G_VIS+2 downto G_VIS));
    LED(3)          <= '1' when FULL(FULL'high downto G_VIS+3) /= 0 else '0';
    
end RTL;




----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/21/2026 04:09:11 PM
-- Design Name: 
-- Module Name: counter_fast - RTL
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use ieee.numeric_std.all;

---- Uncomment the following library declaration if using
---- arithmetic functions with Signed or Unsigned values
----use IEEE.NUMERIC_STD.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx leaf cells in this code.
----library UNISIM;
----use UNISIM.VComponents.all;

--entity counter_fast is
--    generic (
--        G_CHUNKS : integer := 6;    -- at least 2
--        G_WIDTH  : integer := 8    -- at least 4 (LED uses the top 4 bits)
--    );
--    port (
--        i_CLK : in  std_logic;
--        i_RST : in  std_logic;
--        LED   : out std_logic_vector(3 downto 0)
--    );
--end counter_fast;

--architecture RTL of counter_fast is
--    type CNT_t is array (0 to G_CHUNKS-1) of unsigned(G_WIDTH-1 downto 0);
--    signal CNT   : CNT_t := (others => (others => '0'));
--    signal CARRY : std_logic_vector(0 to G_CHUNKS-2) := (others => '0');

--    constant ALL_ONES : unsigned(G_WIDTH-1 downto 0) := (others => '1');
--    constant ALMOST   : unsigned(G_WIDTH-1 downto 0) := ALL_ONES - 1;
--begin

--    process (i_CLK, i_RST)
--    begin
--        if i_RST = '1' then
--            CNT   <= (others => (others => '0'));
--            CARRY <= (others => '0');
--        elsif rising_edge(i_CLK) then
--            CNT(0) <= CNT(0) + 1;

--            -- registered carry flags
--            if CNT(0) = ALMOST then
--                CARRY(0) <= '1';
--            else
--                CARRY(0) <= '0';
--            end if;

--            for i in 1 to G_CHUNKS-2 loop
--                if CARRY(i-1) = '1' and CNT(i) = ALL_ONES then
--                    CARRY(i) <= '1';
--                else
--                    CARRY(i) <= '0';
--                end if;
--            end loop;

--            -- each chunk increments when the previous flag is set
--            for i in 1 to G_CHUNKS-1 loop
--                if CARRY(i-1) = '1' then
--                    CNT(i) <= CNT(i) + 1;
--                end if;
--            end loop;
--        end if;
--    end process;

--    LED <= std_logic_vector(CNT(G_CHUNKS-1)(G_WIDTH-1 downto G_WIDTH-4));

--end RTL;
