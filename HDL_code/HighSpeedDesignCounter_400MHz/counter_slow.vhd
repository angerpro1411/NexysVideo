----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/21/2026 04:00:04 PM
-- Design Name: 
-- Module Name: counter_slow - RTL
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

entity counter_slow is
    port(
        i_CLK : in std_logic;
        i_RST : in std_logic;
        LED   : out std_logic_vector(3 downto 0)
    );
end counter_slow;

architecture RTL of counter_slow is
    signal CNT : unsigned(47 downto 0);
begin

    CNT_PROCESS : process(i_CLK,i_RST)
    begin
        if i_RST = '1' then
            CNT <= (others => '0');
        elsif rising_edge(i_CLK) then
            CNT <= CNT + 1;
        end if;
    end process;
    
    LED <= std_logic_vector(CNT(47 downto 44));
    
end RTL;
