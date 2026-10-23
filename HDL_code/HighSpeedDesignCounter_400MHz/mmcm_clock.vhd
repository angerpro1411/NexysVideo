library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

entity mmcm_clock is
    port (
        sys_clk  : in  std_logic;   -- 100 MHz board clock pin
        clk_fast : out std_logic;   -- generated fast clock (BUFG output)
        locked   : out std_logic
    );
end entity;

architecture rtl of mmcm_clock is
    signal sys_clk_ibuf : std_logic;
    signal sys_clk_bufg : std_logic;
    signal clk_fb       : std_logic;
    signal clk_fb_bufg  : std_logic;
    signal clk_fast_raw : std_logic;
begin

    u_ibuf : IBUF
        port map (I => sys_clk, O => sys_clk_ibuf);

    u_bufg_in : BUFG
        port map (I => sys_clk_ibuf, O => sys_clk_bufg);

    u_mmcm : MMCME2_BASE
        generic map (
            CLKIN1_PERIOD    => 10.0,   -- 100 MHz in
            DIVCLK_DIVIDE    => 1,
            CLKFBOUT_MULT_F  => 10.0,   -- VCO = 100 * 10 = 1000 MHz
            CLKOUT0_DIVIDE_F => 2.5     -- 1000 / 5 = 200 MHz out
        )
        port map (
            CLKIN1   => sys_clk_bufg,
            CLKFBIN  => clk_fb_bufg,
            CLKFBOUT => clk_fb,
            CLKOUT0  => clk_fast_raw,
            LOCKED   => locked,
            PWRDWN   => '0',
            RST      => '0'
        );

    u_bufg_fb : BUFG
        port map (I => clk_fb, O => clk_fb_bufg);

    u_bufg_out : BUFG
        port map (I => clk_fast_raw, O => clk_fast);

end architecture;