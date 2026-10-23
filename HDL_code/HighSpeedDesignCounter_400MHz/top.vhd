----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/21/2026 04:34:56 PM
-- Design Name: 
-- Module Name: top - STRUCTURE
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top is
    port(
        clk100 : in std_logic;
        rst : in std_logic;
        led : out std_logic_vector(3 downto 0)
    );
end top;

architecture STRUCTURE of top is
    signal clk_fast : std_logic;
    signal locked : std_logic := '0';
    
begin
    uut: entity work.counter_fast
    port map(
        i_CLK => clk_fast,
        i_RST => rst,
        LED   => led
    );
    
    clk_gen : entity work.mmcm_clock
        port map(
            sys_clk => clk100,
            clk_fast => clk_fast,
            locked => locked
        );

end STRUCTURE;
