library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MRAM_COMMU is 
    generic(
        CLK_RATE_MHz     : positive := 100;
        -- According to the datasheet : 
        -- Write cycle lasts minimum 45ns => 5 cycles
        -- If W controls writing 25ns => 3 cycles;
        WRITE_DELAY_CYCLE_NS : positive := 45;
        WRITE_PULSE_MIN_NS   : positive := 25;

        -- READ CYCLE TIME 45ns => 5 cycles.
        READ_CYCLE_TIME_NS : positive := 45;
        -- CHIP ENABLE TIME 45ns => 5 cycles.
        CHIP_ENABLE_TIME_NS : positive := 45;

        -- Need 15ns for Next Read after Read, or Read-Write(Bus turnaround)
        READ_TIME_RECOVERY_NS : positive := 15;

        -- Need 12ns to the next write;
        WRITE_TIME_RECOVERY_NS : positive := 12

    );
    port(
        -- if we use 100MHz clock, it means each cycle is 10ns,
        -- we need to use timing to avoid violation setup/hold time.
        i_CLK :         in std_logic;
        i_RST_n :       in std_logic;

        -- Assume that AXI_LITE will command write or read through Register
        -- REG0 : Control : RD/WRn, BLEN, BHEN 
        -- REG1 : STATUS  : ERR, Busy
        -- REG2 : ADDRESS 
        -- REG3 : WR_DATA
        -- REG4 : RD_DATA
        i_START_CMD     : in std_logic;
        i_REG0   :      in std_logic_vector(31 downto 0);
        o_REG1   :      out std_logic_vector(31 downto 0);
        i_REG2   :      in std_logic_vector(31 downto 0);
        i_REG3   :      in std_logic_vector(31 downto 0);
        o_REG4   :      out std_logic_vector(31 downto 0);
        
        --Interrupt for finishing operation.
        INTR     : out std_logic;

        -- Also, it is async ram, so it even take more time to finish a write or a read.
        -- A Writing cycle or Reading cycle takes about 45 ns, compare to 100MHz clk, 
        -- it costs 4-5 cycles.

        E_n :           out std_logic;
        G_n :           out std_logic;
        W_n :           out std_logic;
        ADDR :          out std_logic_vector(17 downto 0);
        UB_n :          out std_logic;
        LB_n :          out std_logic;
        DQ   :          inout std_logic_vector(15 downto 0)
    );
    
end entity;

architecture RTL of MRAM_COMMU is


    type state_t is (IDLE,SET_UP,READ_OPE,READ_HOLD,WRITE_OPE,WRITE_HOLD);
    signal PRE_ST,NX_ST : state_t;

    signal PRE_En,PRE_Gn,PRE_Wn : std_logic;
    signal NX_En,NX_Gn,NX_Wn 	: std_logic;



    signal ADDR_REG,ADDR_NX : std_logic_vector(17 downto 0);
    signal WRITE_DATA_REG,WRITE_DATA_NX : std_logic_vector(15 downto 0);
    signal PRE_CNT,NX_CNT : unsigned(3 downto 0);     
    
    signal PRE_DREAD,NX_DREAD : std_logic_vector(15 downto 0);

    signal BUSY_BIT : std_logic;

    -- READ data
    signal D_READ       : std_logic_vector(15 downto 0);

    -- REG0 Control bit position
    constant BIT_RD_WRn : natural := 0;
    constant BIT_BLEn  : positive := 1;
    constant BIT_BHEn  : positive := 2;


    -- REG1 STATUS bit position
	constant BIT_BUSY   : natural := 0;
    constant BIT_ERR    : natural := 1;
    

----------------------------------Delay cycle calculation----------------------------------
    -- We need to calculate the delay cycle depends on clk, for example 100Mhz
    constant CLK_PERIOD_NS : positive := 1000/CLK_RATE_MHz; 
    -- According to the datasheet : 
    -- Write cycle lasts minimum 45ns => 5 cycles
    -- If W controls writing 25ns => 3 cycles;
    constant WRITE_DELAY_CYCLE : positive := WRITE_DELAY_CYCLE_NS/CLK_PERIOD_NS + 1;
    constant WRITE_PULSE_MIN   : positive := WRITE_PULSE_MIN_NS/CLK_PERIOD_NS + 1;

    -- READ CYCLE TIME 45ns => 5 cycles.
    constant READ_CYCLE_TIME : positive := READ_CYCLE_TIME_NS/CLK_PERIOD_NS + 1;
    constant READ_TIME_RECOVERY : positive := READ_TIME_RECOVERY_NS/CLK_PERIOD_NS + 1;
    -- CHIP ENABLE TIME 45ns => 5 cycles.
    constant CHIP_ENABLE_TIME : positive := CHIP_ENABLE_TIME_NS/CLK_PERIOD_NS + 1;

    constant WRITE_TIME_RECOVERY : positive := WRITE_TIME_RECOVERY_NS/CLK_PERIOD_NS + 1;

    signal WRITE_REST2END_CYCLE : natural range 0 to 20;


begin

    UB_n <= i_REG0(BIT_BHEn);
    LB_n <= i_REG0(BIT_BLEn);

    E_n <= PRE_En;
    G_n <= PRE_Gn;
    W_n <= PRE_Wn;
    ADDR <= ADDR_REG;

    WRITE_REST2END_CYCLE <= (WRITE_DELAY_CYCLE - WRITE_PULSE_MIN) when WRITE_DELAY_CYCLE > (WRITE_PULSE_MIN + WRITE_TIME_RECOVERY) else WRITE_TIME_RECOVERY;

    O_REG4 <= (31 downto 16 => '0') & PRE_DREAD;

    DQ <= WRITE_DATA_REG when PRE_ST = WRITE_OPE or PRE_ST = WRITE_HOLD else (others => 'Z');

    o_REG1 <= (31 downto 1 => '0') & BUSY_BIT;
    BUSY_BIT <= '0' when PRE_ST = IDLE else '1';
    

    STATE_MACHINE : process(i_CLK)
    begin
        if rising_edge(i_CLK) then
            if (i_RST_n = '0') then
                PRE_ST <= IDLE;
                PRE_En <= '1';
                PRE_Gn <= '1';
                PRE_Wn <= '1';
                ADDR_REG <= (others => '0');
                WRITE_DATA_REG <= (others => '0');
                PRE_CNT <= (others => '0');
                PRE_DREAD <= (others => '0');
            else
                PRE_ST <= NX_ST;
                PRE_En <= NX_En;
                PRE_Gn <= NX_Gn;
                PRE_Wn <= NX_Wn;
                ADDR_REG <= ADDR_NX;     
                WRITE_DATA_REG <= WRITE_DATA_NX;
                PRE_CNT <= NX_CNT; 
                PRE_DREAD <= NX_DREAD;          
            end if;
        end if;
    end process;

    NEXT_STATE : process(PRE_ST,PRE_En,PRE_Gn,PRE_Wn,ADDR_REG,
							WRITE_DATA_REG,PRE_CNT,PRE_DREAD,
								i_START_CMD,BUSY_BIT,i_REG0,
								i_REG2,i_REG3,DQ)
    begin
        INTR  <= '0';
        NX_ST <= PRE_ST;
        NX_En <= PRE_En;
        NX_Gn <= PRE_Gn;
        NX_Wn <= PRE_Wn;
        ADDR_NX <= ADDR_REG;
        WRITE_DATA_NX <= WRITE_DATA_REG; 
        NX_CNT <= PRE_CNT;
        NX_DREAD <= PRE_DREAD;
        case PRE_ST is 
            when IDLE =>
                NX_ST <= IDLE;
                NX_En <= '1';
                NX_Gn <= '1';
                NX_Wn <= '1';
                ADDR_NX <= ADDR_REG;
                NX_CNT <= (others => '0'); 
                if (i_START_CMD = '1' and BUSY_BIT = '0') then
                    NX_ST <= SET_UP;
                    NX_En <= '0';
                    ADDR_NX <= i_REG2(17 downto 0);
                    NX_CNT <= (others => '0');                                              
                end if;
            when SET_UP =>
                if i_REG0(BIT_RD_WRn) = '1' then
                    NX_ST <= READ_OPE;
                    NX_Wn <= '1';
                    NX_Gn <= '0';
                    NX_CNT <= (others => '0');                        
                elsif i_REG0(BIT_RD_WRn) = '0' then -- Write active low
                    NX_ST <= WRITE_OPE;
                    NX_Wn <= '0';
                    NX_Gn <= '1';
                    -- Time between 
                    WRITE_DATA_NX <= i_REG3(15 downto 0);
                    NX_CNT <= (others => '0');                         
                end if;                        
            when READ_OPE =>
                NX_ST <= READ_OPE;
                NX_En <= '0';
                NX_Wn <= '1';
                NX_Gn <= '0';
                ADDR_NX <= ADDR_REG;  

                -- Working as a counter 
                NX_CNT <= PRE_CNT + 1;                        
                if PRE_CNT = READ_CYCLE_TIME - 1 then
                    NX_ST <= READ_HOLD;
                    NX_En <= '0';
                    NX_Wn <= '1';
                    NX_Gn <= '1';
                    ADDR_NX <= ADDR_REG;  
    
                    -- Reset counter 
                    NX_CNT <= (others => '0');
                    
                    -- DATA is READY to be read
                    NX_DREAD <= DQ;

                    INTR <= '1';
                end if;
            when READ_HOLD =>
                NX_En <= '1';
                NX_CNT <= PRE_CNT + 1;
                if PRE_CNT = READ_TIME_RECOVERY -1 then
                    NX_CNT <= (others => '0');
                    NX_ST <= IDLE;
                end if;
            when WRITE_OPE =>
                NX_ST <= WRITE_OPE;
                NX_En <= '0';
                NX_Wn <= '0';
                ADDR_NX <= ADDR_REG;
                WRITE_DATA_NX <= WRITE_DATA_REG;

                -- Working as a counter 
                NX_CNT <= PRE_CNT + 1;                
                if PRE_CNT > WRITE_PULSE_MIN-1 then
                    NX_Wn <= '1';
                    NX_ST <= WRITE_HOLD;
                    -- Reset counter
                    NX_CNT <= (others => '0'); 
                    INTR <= '1';                   
                end if;
            when WRITE_HOLD =>
                -- Working as a counter 
                NX_CNT <= PRE_CNT + 1;
                
                -- There is no clear rule show delay time between WE and CE
                -- after WE deasserts, so delay only one cycle
                NX_EN <= '1';
                
                -- Time Delay either for writing recovery time or minimum time
                -- of writing operation. 
                if PRE_CNT = WRITE_REST2END_CYCLE-1 then
                    NX_ST <= IDLE;
                    NX_CNT <= (others => '0');
                end if;
            when others =>
                NX_ST <= PRE_ST;
                NX_En <= PRE_En;
                NX_Gn <= PRE_Gn;
                NX_Wn <= PRE_Wn;
                ADDR_NX <= ADDR_REG;
                WRITE_DATA_NX <= WRITE_DATA_REG; 
                NX_CNT <= PRE_CNT;
                NX_DREAD <= PRE_DREAD;
        end case;                     
    end process;
end architecture;
