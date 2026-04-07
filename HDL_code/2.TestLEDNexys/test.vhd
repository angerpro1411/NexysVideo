----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06.03.2026 11:03:57
-- Design Name: 
-- Module Name: led_n_button - RTL
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

entity led_n_button is
  Port (
        CLK_100M        : in std_logic;       
        RST_n           : in std_logic;
        CHANGE_STATE    : in std_logic;
        I_SWITCH        : in std_logic_vector(7 downto 0);
        O_LED           : out std_logic_vector(7 downto 0)
   );
end led_n_button;

architecture RTL of led_n_button is
     type STATE_t is (AUTO,MANUAL);
     signal my_state : STATE_t;
     
     
     signal CNT_to_2500000 : unsigned(21 downto 0);
     signal CNT_to_256 : unsigned(7 downto 0);
     
     signal CLK_5M : std_logic;
     
     component clk_wiz_0
         port
         (-- Clock in ports
          -- Clock out ports
          clk_out1          : out    std_logic;
          clk_in1           : in     std_logic
         );
     end component;
     
begin

   your_instance_name : clk_wiz_0
   port map ( 
  -- Clock out ports  
   clk_out1 => CLK_5M,
   -- Clock in ports
   clk_in1 => CLK_100M
   );

    CNT_2_2500000_PROC: process(CLK_5M)
    begin
        if rising_edge(CLK_5M) then
            if RST_n = '0' then
                CNT_to_2500000 <= (others => '0');
            else
                CNT_to_2500000 <= CNT_to_2500000 + 1;
                if CNT_to_2500000 = 2499999 then
                    CNT_to_2500000 <= (others => '0');
                end if;
            end if;
        end if;
    end process;

    CNT_2_256_PROC : process(CLK_5M) 
    begin
        if rising_edge(CLK_5M) then
            if RST_n = '0' then
                CNT_to_256 <= (others => '0');
            elsif CNT_to_2500000 = 2499999 then
                CNT_to_256 <= CNT_to_256 + 1;
            end if;
        end if;
    end process;
    
    STATE_FLIP : process(CLK_5M)
    begin
        if rising_edge(CLK_5M) then
            if RST_n = '0' then
                my_state <= AUTO;
            else
                if CHANGE_STATE = '1' and my_state = AUTO then
                    my_state <= MANUAL;
                elsif CHANGE_STATE = '1' and my_state = MANUAL then
                    my_state <= AUTO;
                end if;
            end if;
        end if;
    end process;

    O_LED_PROC : process(CLK_5M)
    begin
        if rising_edge(CLK_5M) then
            if (RST_n = '0') then
                O_LED <= (others => '1');
            else
                if my_state = MANUAL then
                    O_LED <= I_SWITCH;
                elsif my_state = AUTO then
                    O_LED <= std_logic_vector(CNT_to_256);
                end if;
            end if;
        end if;
    end process;

end RTL;
