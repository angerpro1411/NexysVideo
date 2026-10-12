----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Duy-Manh NGUYEN
-- 
-- Create Date: 04/30/2024 02:32:56 PM
-- Design Name: 
-- Module Name: AXI_LITE_SLAVE - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- Follow the xilinx slave example
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- https://www.realdigital.org/doc/a9fee931f7a172423e1ba73f66ca4081
-- https://docs.amd.com/v/u/en-US/axi_lite_ipif_ds765
-- https://docs.amd.com/v/u/en-US/pg155-axi-lite-ipif
-- How to perform Read and Write AXI-LITE in C Vitis : https://www.youtube.com/watch?v=MbteffkRi8Y
----------------------------------------------------------------------------------



LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;



entity AXIL_SLAVE_ARBITRATOR is
	GENERIC(
		DATA_WIDTH		: integer := 32;
		STROBE_WIDTH	: integer := 4; -- datawidth / 4
	
		AXIL_ADDR_WIDTH : positive := 32;
        NUM_AXIL_MASTERS: positive := 4;
		PERIPH_BASE_ADDR: std_logic_vector(31 downto 0):=x"30000000";

        -- instead of using distance for axil slave, I define number of maximum allocation registers
        -- for each axil slave. 
        AXIL_SLAVE_MAX_NUMB_REGISTERS : positive := 256
	);
	PORT(
	    
	  --USER Input and Output
        -- N AXI-Lite master interfaces
        M_AXIL_AWVALID : out std_logic_vector(NUM_AXIL_MASTERS-1 downto 0);
        M_AXIL_AWADDR  : out std_logic_vector(
            NUM_AXIL_MASTERS*AXIL_ADDR_WIDTH-1 downto 0
        );
        M_AXIL_AWREADY : in std_logic_vector(NUM_AXIL_MASTERS-1 downto 0);

        M_AXIL_WVALID : out std_logic_vector(NUM_AXIL_MASTERS-1 downto 0);
        M_AXIL_WDATA  : out std_logic_vector(
            NUM_AXIL_MASTERS*DATA_WIDTH-1 downto 0
        );
        M_AXIL_WSTRB : out std_logic_vector(
            NUM_AXIL_MASTERS*(DATA_WIDTH/8)-1 downto 0
        );
        M_AXIL_WREADY : in std_logic_vector(NUM_AXIL_MASTERS-1 downto 0);

        M_AXIL_BREADY : out std_logic_vector(NUM_AXIL_MASTERS-1 downto 0);
        M_AXIL_BVALID : in std_logic_vector(NUM_AXIL_MASTERS-1 downto 0);
        M_AXIL_BRESP  : in std_logic_vector(
            NUM_AXIL_MASTERS*2-1 downto 0
        );

        M_AXIL_ARVALID : out std_logic_vector(NUM_AXIL_MASTERS-1 downto 0);
        M_AXIL_ARADDR  : out std_logic_vector(
            NUM_AXIL_MASTERS*AXIL_ADDR_WIDTH-1 downto 0
        );
        M_AXIL_ARREADY : in std_logic_vector(NUM_AXIL_MASTERS-1 downto 0);

        M_AXIL_RVALID : in std_logic_vector(NUM_AXIL_MASTERS-1 downto 0);
        M_AXIL_RDATA  : in std_logic_vector(
            NUM_AXIL_MASTERS*DATA_WIDTH-1 downto 0
        );
        M_AXIL_RREADY : out std_logic_vector(NUM_AXIL_MASTERS-1 downto 0);
        M_AXIL_RRESP : in std_logic_vector(
            NUM_AXIL_MASTERS*2-1 downto 0
        );

	  ---------------------------------------------------------------------

    
		----------------------------Global signal----------------------------
		S_AXI_ACLK 		: in std_logic;
		S_AXI_RESETN		: in std_logic;
		
		----------------------------Write address channel----------------------------
		
		--Write address valid. Indicate that Master signaling valid address and control information.
		S_AXI_AWVALID		: in std_logic;
		
		--Write address ready. Indicate that Slave is ready to accept an address.
		S_AXI_AWREADY		: out std_logic;
		
		--Write address, issue by master, accepted by slave.
		S_AXI_AWADDR		: in std_logic_vector(AXIL_ADDR_WIDTH-1 downto 0);
			
		----------------------------Write data channel----------------------------
		
		--Writa date, issue by Master, accepted by Slave.
		S_AXI_WDATA		: in std_logic_vector(DATA_WIDTH-1 downto 0);
		
		--Write strobe. Indicate which bytes lane hold valid data. Each bit
		--of strobe corressponde to one byte valid data. Check code for deeply understanding.
		S_AXI_WSTRB		: in std_logic_vector(STROBE_WIDTH-1 downto 0);
		
		--Write valid. Indicate valid data is on bus and strobes are available
		S_AXI_WVALID		: in std_logic;
		
		--Write ready. Slave is ready to accept data.
		S_AXI_WREADY		: out std_logic;
		
		----------------------------Write response channel----------------------------
		
		--Response ready. Master can accept the response without problem.
		S_AXI_BREADY		: in std_logic;
		
		--Write response valid. Signaling that the write reponse is valid.
		S_AXI_BVALID		: out std_logic;
		
		--Write response. The status of write transaction "Good, ...." 4 result for 2-bit.
		S_AXI_BRESP		: out std_logic_vector(1 downto 0);
		
		------------------------------Read address channel----------------------------
		
		--Read Address. issue by Master, accepted by Slave.
		S_AXI_ARADDR		: in std_logic_vector(AXIL_ADDR_WIDTH-1 downto 0);
				
		--Read address valid. address from Master is valid, and Slave can accept it.
		S_AXI_ARVALID		: in std_logic;
		
		--Read address ready. Slave is ready to accept the read address from Master.
		S_AXI_ARREADY	: out std_logic;
		
		------------------------------Read data channel----------------------------
		
		--Read data, issued by Slave, Master accept it.
		S_AXI_RDATA		: out std_logic_vector(DATA_WIDTH-1 downto 0);
		
		--Read response. Status of read transaction.
		S_AXI_RRESP		: out std_logic_vector(1 downto 0);
			
		--Read valid, signaling data from Slave is fresh and Master can accept it.
		S_AXI_RVALID		: out std_logic;
		
		--Read ready, Master is ready to receive the data from Slave.
		S_AXI_RREADY		: in std_logic -- Master tells ready to read
		
	);
	
end entity;

architecture RTL of AXIL_SLAVE_ARBITRATOR is


    component AXIL_MASTER
        generic (
            ADDR_WIDTH : integer := 32;
            DATA_WIDTH : integer := 32
        );
        port (
            START_WRITE : in std_logic;
            WR_ADDR     : in std_logic_vector(ADDR_WIDTH-1 downto 0);
            WR_DATA     : in std_logic_vector(DATA_WIDTH-1 downto 0);
            WR_STRB     : in std_logic_vector(DATA_WIDTH/8-1 downto 0);

            START_READ  : in std_logic;
            RD_ADDR     : in std_logic_vector(ADDR_WIDTH-1 downto 0);

            RD_DATA            : out std_logic_vector(DATA_WIDTH-1 downto 0);
            RD_DATA_VALID      : out std_logic;
            HOST_RD_DATA_READY : in std_logic;

            WR_BUSY : out std_logic;
            ERR_WR  : out std_logic;
            ERR_RD  : out std_logic;

            M_AXIL_ACLK : in std_logic;
            M_AXIL_RSTN : in std_logic;

            M_AXIL_AWVALID : out std_logic;
            M_AXIL_AWADDR  : out std_logic_vector(ADDR_WIDTH-1 downto 0);
            M_AXIL_AWREADY : in std_logic;

            M_AXIL_WVALID : out std_logic;
            M_AXIL_WDATA  : out std_logic_vector(DATA_WIDTH-1 downto 0);
            M_AXIL_WSTRB  : out std_logic_vector(DATA_WIDTH/8-1 downto 0);
            M_AXIL_WREADY : in std_logic;

            M_AXIL_BREADY : out std_logic;
            M_AXIL_BVALID : in std_logic;
            M_AXIL_BRESP  : in std_logic_vector(1 downto 0);

            M_AXIL_ARVALID : out std_logic;
            M_AXIL_ARADDR  : out std_logic_vector(ADDR_WIDTH-1 downto 0);
            M_AXIL_ARREADY : in std_logic;

            M_AXIL_RVALID : in std_logic;
            M_AXIL_RDATA  : in std_logic_vector(DATA_WIDTH-1 downto 0);
            M_AXIL_RREADY : out std_logic;
            M_AXIL_RRESP  : in std_logic_vector(1 downto 0)
        );
    end component;



    --
    -- Function/Procedure
    --
    
    -- this function is working in elaboration time
    function LOG2( 
        x_in : positive
    )return integer is
        variable NUMB_BITS: integer range 0 to 32;
        variable X : positive := x_in;
    begin
        NUMB_BITS := 0;
        while (X > 1) loop
            assert (X mod 2) = 0
                report "Value should be power of 2"
                severity failure;
            X := X/2;
            NUMB_BITS := NUMB_BITS + 1;
        end loop;
        return NUMB_BITS;
    end function;

    constant NUMB_BITS_4_DIST : integer := LOG2(AXIL_SLAVE_MAX_NUMB_REGISTERS) + 2;

    -- work in run time
    procedure WHICH_PERIPH_FUNC(
        signal ACTUAL_ADDR : in std_logic_vector(AXIL_ADDR_WIDTH-1 downto 0);
        BASE_ADDR : in std_logic_vector(AXIL_ADDR_WIDTH-1 downto 0);
        signal I : out integer range 0 to 1023;
        signal ERR : out std_logic
    ) is
        variable DIFF : unsigned(AXIL_ADDR_WIDTH-1 downto 0);
        variable I_TEMP : integer;
        begin
            ERR <= '0';
            if unsigned(ACTUAL_ADDR) < unsigned(BASE_ADDR) then
                I <= 0;
                ERR <= '1';
            else
                DIFF := unsigned(ACTUAL_ADDR) - unsigned(BASE_ADDR);
                I_TEMP := to_integer(shift_right(DIFF,NUMB_BITS_4_DIST));
                if I_TEMP > (NUM_AXIL_MASTERS-1) then
                    I <= 0;
                    ERR <= '1';
                else
                    I <= I_TEMP;
                end if;
            end if;
    end procedure WHICH_PERIPH_FUNC;
    
    signal ADDR_ERR_WR,ADDR_ERR_RD : std_logic;
	
	--AXILITE signals to transactions
	signal WRITEnAWRITE_VALID_EN: std_logic;
	signal B_HANDSHAKE_EN : std_logic;
	
	signal AR_HANDSHAKE_EN: std_logic;
	signal R_HANDSHAKE_EN: std_logic;
	
	
	--Enable write to slave
	signal WR_TO_SLAVE_REG_EN : std_logic;
	--Enable read from slave.
	signal RD_TRANSACTION_DONE : std_logic;
	
	--AW_PENDING uses to write data one cycle after 
	signal AW_PENDING : std_logic;
	signal WR_PENDING,AR_PENDING  : std_logic;

	--buffer signals for output
    signal AXI_BVALID,AXI_AWREADY,AXI_WREADY,AXI_ARREADY,AXI_RVALID : std_logic;
    
    -- reg for storing write address
	signal AXI_AWADDR,AXI_ARADDR : std_logic_vector(AXIL_ADDR_WIDTH-1 downto 0);
    signal PERIPH_VALID : std_logic;


    signal AXI_WDATA : std_logic_vector(DATA_WIDTH-1 downto 0);
	-- reg for storing write strobe at the same time with write data.
	signal AXI_WSTRB : std_logic_vector(STROBE_WIDTH-1 downto 0);
	
	signal AXI_RDATA : std_logic_vector(DATA_WIDTH-1 downto 0);
	
    -- ============================================================
    -- User / Processor interface
    -- ============================================================

    type START_WRITE_t is array (0 to NUM_AXIL_MASTERS-1) of std_logic;
    signal start_write : START_WRITE_t;

    type WR_ADDR_t is array (0 to NUM_AXIL_MASTERS-1)
        of std_logic_vector(AXIL_ADDR_WIDTH-1 downto 0);
    signal wr_addr : WR_ADDR_t;

    type WR_DATA_t is array (0 to NUM_AXIL_MASTERS-1)
        of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal wr_data : WR_DATA_t;

    type WR_STRB_t is array (0 to NUM_AXIL_MASTERS-1)
        of std_logic_vector(STROBE_WIDTH-1 downto 0);
    signal wr_strb : WR_STRB_t;


    type START_READ_t is array (0 to NUM_AXIL_MASTERS-1) of std_logic;
    signal start_read : START_READ_t;

    type RD_ADDR_t is array (0 to NUM_AXIL_MASTERS-1)
        of std_logic_vector(AXIL_ADDR_WIDTH-1 downto 0);
    signal rd_addr : RD_ADDR_t;


    -- ============================================================
    -- Read data returned to host
    -- ============================================================

    type RD_DATA_t is array (0 to NUM_AXIL_MASTERS-1)
        of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal rd_data : RD_DATA_t;

    type RD_DATA_VALID_t is array (0 to NUM_AXIL_MASTERS-1)
        of std_logic;
    signal rd_data_valid : RD_DATA_VALID_t;

    type HOST_RD_DATA_READY_t is array (0 to NUM_AXIL_MASTERS-1)
        of std_logic;
    signal host_rd_data_ready : HOST_RD_DATA_READY_t;


    -- ============================================================
    -- Status
    -- ============================================================

    type WR_BUSY_t is array (0 to NUM_AXIL_MASTERS-1)
        of std_logic;
    signal wr_busy : WR_BUSY_t;

    type ERR_WR_t is array (0 to NUM_AXIL_MASTERS-1)
        of std_logic;
    signal err_wr : ERR_WR_t;

    type ERR_RD_t is array (0 to NUM_AXIL_MASTERS-1)
        of std_logic;
    signal err_rd : ERR_RD_t;


    -- ============================================================
    -- AXI-Lite Write Address Channel
    -- ============================================================

    type AXIL_AWVALID_t is array (0 to NUM_AXIL_MASTERS-1)
        of std_logic;
    signal axil_awvalid : AXIL_AWVALID_t;

    type AXIL_AWADDR_t is array (0 to NUM_AXIL_MASTERS-1)
        of std_logic_vector(AXIL_ADDR_WIDTH-1 downto 0);
    signal axil_awaddr : AXIL_AWADDR_t;

    type AXIL_AWREADY_t is array (0 to NUM_AXIL_MASTERS-1)
        of std_logic;
    signal axil_awready : AXIL_AWREADY_t;


    -- ============================================================
    -- AXI-Lite Write Data Channel
    -- ============================================================

    type AXIL_WVALID_t is array (0 to NUM_AXIL_MASTERS-1)
        of std_logic;
    signal axil_wvalid : AXIL_WVALID_t;

    type AXIL_WDATA_t is array (0 to NUM_AXIL_MASTERS-1)
        of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal axil_wdata : AXIL_WDATA_t;

    type AXIL_WSTRB_t is array (0 to NUM_AXIL_MASTERS-1)
        of std_logic_vector(DATA_WIDTH/8-1 downto 0);
    signal axil_wstrb : AXIL_WSTRB_t;

    type AXIL_WREADY_t is array (0 to NUM_AXIL_MASTERS-1)
        of std_logic;
    signal axil_wready : AXIL_WREADY_t;


    -- ============================================================
    -- AXI-Lite Write Response Channel
    -- ============================================================

    type AXIL_BREADY_t is array (0 to NUM_AXIL_MASTERS-1)
        of std_logic;
    signal axil_bready : AXIL_BREADY_t;

    type AXIL_BVALID_t is array (0 to NUM_AXIL_MASTERS-1)
        of std_logic;
    signal axil_bvalid : AXIL_BVALID_t;

    type AXIL_BRESP_t is array (0 to NUM_AXIL_MASTERS-1)
        of std_logic_vector(1 downto 0);
    signal axil_bresp : AXIL_BRESP_t;


    -- ============================================================
    -- AXI-Lite Read Address Channel
    -- ============================================================

    type AXIL_ARVALID_t is array (0 to NUM_AXIL_MASTERS-1)
        of std_logic;
    signal axil_arvalid : AXIL_ARVALID_t;

    type AXIL_ARADDR_t is array (0 to NUM_AXIL_MASTERS-1)
        of std_logic_vector(AXIL_ADDR_WIDTH-1 downto 0);
    signal axil_araddr : AXIL_ARADDR_t;

    type AXIL_ARREADY_t is array (0 to NUM_AXIL_MASTERS-1)
        of std_logic;
    signal axil_arready : AXIL_ARREADY_t;


    -- ============================================================
    -- AXI-Lite Read Data Channel
    -- ============================================================

    type AXIL_RVALID_t is array (0 to NUM_AXIL_MASTERS-1)
        of std_logic;
    signal axil_rvalid : AXIL_RVALID_t;

    type AXIL_RDATA_t is array (0 to NUM_AXIL_MASTERS-1)
        of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal axil_rdata : AXIL_RDATA_t;

    type AXIL_RREADY_t is array (0 to NUM_AXIL_MASTERS-1)
        of std_logic;
    signal axil_rready : AXIL_RREADY_t;

    type AXIL_RRESP_t is array (0 to NUM_AXIL_MASTERS-1)
        of std_logic_vector(1 downto 0);
    signal axil_rresp : AXIL_RRESP_t;


    -- which periph
    signal WHICH_PERIPH_WR, WHICH_PERIPH_RD : integer range 0 to 1023;

    -- signals force reset if rd/wr address is wrong
    signal RST_PROC_BY_ADDR_ERR_RD,RST_PROC_BY_ADDR_ERR_WR : std_logic;

begin

    -- AXIL MASTER instantiation
    GEN_AXIL_MASTER : for I in 0 to NUM_AXIL_MASTERS-1 generate
        AXIL_MASTER_INST : AXIL_MASTER
            generic map (
                ADDR_WIDTH => AXIL_ADDR_WIDTH,
                DATA_WIDTH => DATA_WIDTH
            )
            port map (
                START_WRITE => start_write(i),

                WR_ADDR => wr_addr(i),
                WR_DATA => wr_data(i),
                WR_STRB => wr_strb(i),

                START_READ => start_read(i),
                RD_ADDR   => rd_addr(i),

                RD_DATA            => rd_data(i),
                RD_DATA_VALID      => rd_data_valid(i),
                HOST_RD_DATA_READY => host_rd_data_ready(i),

                WR_BUSY => wr_busy(i),
                ERR_WR  => err_wr(i),
                ERR_RD  => err_rd(i),

                M_AXIL_ACLK => S_AXI_ACLK,
                M_AXIL_RSTN => S_AXI_RESETN,

                M_AXIL_AWVALID => axil_awvalid(i),
                M_AXIL_AWADDR  => axil_awaddr(i),
                M_AXIL_AWREADY => axil_awready(i),

                M_AXIL_WVALID => axil_wvalid(i),
                M_AXIL_WDATA  => axil_wdata(i),
                M_AXIL_WSTRB  => axil_wstrb(i),
                M_AXIL_WREADY => axil_wready(i),

                M_AXIL_BREADY => axil_bready(i),
                M_AXIL_BVALID => axil_bvalid(i),
                M_AXIL_BRESP  => axil_bresp(i),

                M_AXIL_ARVALID => axil_arvalid(i),
                M_AXIL_ARADDR  => axil_araddr(i),
                M_AXIL_ARREADY => axil_arready(i),

                M_AXIL_RVALID => axil_rvalid(i),
                M_AXIL_RDATA  => axil_rdata(i),
                M_AXIL_RREADY => axil_rready(i),
                M_AXIL_RRESP  => axil_rresp(i)        
            );

    end generate;

    GEN_CONNECT_SIGNAL_AXI : for i in 0 to NUM_AXIL_MASTERS-1 generate
                M_AXIL_AWVALID(i) <= axil_awvalid(i);
                M_AXIL_AWADDR(AXIL_ADDR_WIDTH*(i+1)-1 downto 
                                                AXIL_ADDR_WIDTH*i) <= axil_awaddr(i);
                axil_awready(i) <= M_AXIL_AWREADY(i);

                M_AXIL_WVALID(i) <= axil_wvalid(i);
                M_AXIL_WDATA(DATA_WIDTH*(i+1)-1 downto 
                                                DATA_WIDTH*i) <= axil_wdata(i);
                M_AXIL_WSTRB((DATA_WIDTH/8)*(i+1)-1 downto 
                                                (DATA_WIDTH/8)*i) <= axil_wstrb(i);
                axil_wready(i) <= M_AXIL_WREADY(i);

                M_AXIL_BREADY(i) <= axil_bready(i);
                axil_bvalid(i) <= M_AXIL_BVALID(i);
                axil_bresp(i)  <= M_AXIL_BRESP(2*(i+1)-1 downto 
                                                2*i);

                M_AXIL_ARVALID(i) <= axil_arvalid(i);
                M_AXIL_ARADDR(AXIL_ADDR_WIDTH*(i+1)-1 downto 
                                                AXIL_ADDR_WIDTH*i) <= axil_araddr(i);
                axil_arready(i) <= M_AXIL_ARREADY(i);

                axil_rvalid(i) <= M_AXIL_RVALID(i);
                axil_rdata(i)  <= M_AXIL_RDATA(DATA_WIDTH*(i+1)-1 downto 
                                                DATA_WIDTH*i);
                M_AXIL_RREADY(i) <= axil_rready(i);
                axil_rresp(i)  <= M_AXIL_RRESP(2*(i+1)-1 downto 
                                                2*i);  
    end generate;


    --Connect buffers and outputs
    S_AXI_BVALID <= AXI_BVALID;
    S_AXI_AWREADY <= AXI_AWREADY;
    S_AXI_WREADY <= AXI_WREADY;
    S_AXI_ARREADY <= AXI_ARREADY;
    S_AXI_RVALID <= AXI_RVALID;
    

    -- Based on ADAM rule, each AXIL peripheral have address range by 400.
    -- Start by 0x3000-0000, so first periph will be range from 
    -- 0x3000-0000 to 0x3000-03FF, next from 0x3000-0400 to 0x3000-07FF, etcc
    -- So we use it to decide which axi-lite will get write/read command.

	-- WRITE ADDRESS process
	-- AW_READY_PROC: process(S_AXI_ACLK)
	-- begin
	-- 	if rising_edge(S_AXI_ACLK) then
	-- 		if (S_AXI_RESETN = '0') then
	-- 			AXI_AWREADY <= '1';
	-- 			AW_PENDING <= '0';
	-- 		else
	-- 			if AXI_AWREADY = '1' and S_AXI_AWVALID = '1' then
	-- 				AXI_AWREADY <= '0';
	-- 				AW_PENDING <= '1';
	-- 			elsif WR_TO_SLAVE_REG_EN = '1' then
	-- 				AXI_AWREADY <= '1';
	-- 				AW_PENDING <= '0';
	-- 			end if;
	-- 		end if;
	-- 	end if;
	-- end process;

	AW_READY_PROC: process(S_AXI_ACLK)
	begin
		if rising_edge(S_AXI_ACLK) then
			if (S_AXI_RESETN = '0') then
				AXI_AWREADY <= '1';
				AW_PENDING <= '0';
			else
				if AXI_AWREADY = '1' and S_AXI_AWVALID = '1' then
					AXI_AWREADY <= '0';
					AW_PENDING <= '1';
				elsif AXI_BVALID = '1' and S_AXI_BREADY = '1' then
					AXI_AWREADY <= '1';
					AW_PENDING <= '0';
                --Force reset process by err
                -- elsif RST_PROC_BY_ADDR_ERR_WR = '1' then 
				-- 	AXI_AWREADY <= '1';
				-- 	AW_PENDING <= '0';                   
				end if;
			end if;
		end if;
	end process;


	AW_DATA_PROC: process(S_AXI_ACLK)
	begin
		if rising_edge(S_AXI_ACLK) then
			if (S_AXI_RESETN = '0') then
				AXI_AWADDR <= (others => '0');
			else
				if AXI_AWREADY = '1' and S_AXI_AWVALID = '1' then
					AXI_AWADDR <= S_AXI_AWADDR;
				end if;
			end if;
		end if;
	end process;


    PERIPH_DECISION_WR: process(S_AXI_ACLK)
    begin
        if rising_edge(S_AXI_ACLK) then
            if (S_AXI_RESETN = '0') then
                WHICH_PERIPH_WR <= 0;
                ADDR_ERR_WR <= '0';
            else
                if AXI_AWREADY = '1' and S_AXI_AWVALID = '1' then
                            WHICH_PERIPH_FUNC(S_AXI_AWADDR,
                                                PERIPH_BASE_ADDR,
                                                WHICH_PERIPH_WR,
                                                ADDR_ERR_WR
                            );
                end if;
            end if;
        end if;
    end process;


	W_READY_PROC: process(S_AXI_ACLK)
	begin
		if rising_edge(S_AXI_ACLK) then
			if (S_AXI_RESETN = '0') then
				AXI_WREADY <= '1';
				WR_PENDING <= '0';
			else
				if AXI_WREADY = '1' and S_AXI_WVALID = '1' then
					AXI_WREADY <= '0';
					WR_PENDING <= '1';
				elsif AXI_BVALID = '1' and S_AXI_BREADY = '1' then
					AXI_WREADY <= '1';
					WR_PENDING <= '0';
                -- --Force reset process by err
                -- elsif RST_PROC_BY_ADDR_ERR_WR = '1' then
				-- 	AXI_WREADY <= '1';
				-- 	WR_PENDING <= '0';                    
				end if;
			end if;
		end if;
	end process;

	W_DATA_PROC: process(S_AXI_ACLK)
	begin
		if rising_edge(S_AXI_ACLK) then
			if (S_AXI_RESETN = '0') then
				AXI_WDATA <= (others => '0');
				AXI_WSTRB <= (others => '0');
			else
				if AXI_WREADY = '1' and S_AXI_WVALID = '1' then
					AXI_WDATA <= S_AXI_WDATA;
					AXI_WSTRB <= S_AXI_WSTRB;
				end if;
			end if;
		end if;
	end process;	

	WR_TO_SLAVE_REG_EN <= '1' when (AW_PENDING = '1' 
                                    and WR_PENDING = '1'
                                    and (WR_BUSY(WHICH_PERIPH_WR) = '0')
                                    and ADDR_ERR_WR = '0'
                                    )else '0';

	WR_TO_PERIPH : process(S_AXI_ACLK)
    begin
    	if rising_edge(S_AXI_ACLK) then
    		if S_AXI_RESETN = '0' then
				for I in 0 to NUM_AXIL_MASTERS-1 loop 
					START_WRITE(I) <= '0'; 	
                    WR_ADDR(I) <= x"DEADC0DE";
                    WR_DATA(I) <= x"DEADC0DE";
                    WR_STRB(I) <= x"F";		
				end loop;
			else
				for I in 0 to NUM_AXIL_MASTERS-1 loop 
					START_WRITE(I) <= '0'; 	
				end loop;

				if WR_TO_SLAVE_REG_EN = '1' then
					START_WRITE(WHICH_PERIPH_WR) <= '1'; 	
                    WR_ADDR(WHICH_PERIPH_WR) <= AXI_AWADDR;
                    WR_DATA(WHICH_PERIPH_WR) <= AXI_WDATA;
                    WR_STRB(WHICH_PERIPH_WR) <= AXI_WSTRB;	                    
                end if;
			end if;
		end if;					
    end process;

	-- Bvalid control for total write process
	B_VALID_PROC: process(S_AXI_ACLK)
    begin
    	if rising_edge(S_AXI_ACLK) then
    		if S_AXI_RESETN = '0' then
				AXI_BVALID <= '0';
			else
				if (AXIL_BVALID(WHICH_PERIPH_WR) = '1'
                    and AXIL_BREADY(WHICH_PERIPH_WR) = '1') then
					AXI_BVALID <= '1';
				elsif AXI_BVALID = '1' and S_AXI_BREADY = '1' then
					AXI_BVALID <= '0';

                -- still issue axi bvalid for error case
                elsif RST_PROC_BY_ADDR_ERR_WR = '1' then
                    AXI_BVALID <= '1';                 
				end if;
			end if;
		end if;		
	end process;

    -- Reset proc by ERR
    -- If address is wrong, we force to reset the process, or aw_pending
    -- and w_pending will wait forever. 
    -- This reset only happend when write is pending, aw is pending, 
    -- but address is wrong
    -- only one pulse after data-address pending but false.
    
    ADDR_ERR_WR_CREATE_SIGNAL: process(S_AXI_ACLK)
    begin
        if rising_edge(S_AXI_ACLK) then
            if S_AXI_RESETN = '0' then
                RST_PROC_BY_ADDR_ERR_WR <= '0';
            else
                if AXI_BVALID = '1' and S_AXI_BREADY = '1' then
                    RST_PROC_BY_ADDR_ERR_WR <= '0';
                elsif ADDR_ERR_WR = '1' and 
                WR_PENDING = '1'  and AW_PENDING = '1' then
                    RST_PROC_BY_ADDR_ERR_WR <= '1';
                end if;
            end if;
        end if;
    end process;

	--Simplify the BRESPONSE
	S_AXI_BRESP <= AXIL_BRESP(WHICH_PERIPH_WR) when ADDR_ERR_WR /= '1' else "11";


	-- Read channel implementation
	AR_READY_PROC: process(S_AXI_ACLK)
	begin
		if rising_edge(S_AXI_ACLK) then
			if (S_AXI_RESETN = '0') then
				AXI_ARREADY <= '1';
				AR_PENDING <= '0';
			else
				if AXI_ARREADY = '1' and S_AXI_ARVALID = '1' then
					AXI_ARREADY <= '0';
					AR_PENDING <= '1';
				elsif RD_TRANSACTION_DONE = '1' then
					AXI_ARREADY <= '1';
					AR_PENDING <= '0';

                -- force reset proc by err
                -- elsif RST_PROC_BY_ADDR_ERR_RD = '1' then
				-- 	AXI_ARREADY <= '1';
				-- 	AR_PENDING <= '0';                
				end if;
			end if;
		end if;
	end process;

	AR_DATA_PROC: process(S_AXI_ACLK)
	begin
		if rising_edge(S_AXI_ACLK) then
			if (S_AXI_RESETN = '0') then
				AXI_ARADDR <= (others => '0');
			else
				if AXI_ARREADY = '1' and S_AXI_ARVALID = '1' then
					AXI_ARADDR <= S_AXI_ARADDR;
				end if;
			end if;
		end if;
	end process;


    PERIPH_RD_DECISION: process(S_AXI_ACLK)
    begin
        if rising_edge(S_AXI_ACLK) then
            if (S_AXI_RESETN = '0') then
                WHICH_PERIPH_RD <= 0;
                PERIPH_VALID <= '0';
                ADDR_ERR_RD <= '0';
            else
                PERIPH_VALID <= '0';
                if AXI_ARREADY = '1' and S_AXI_ARVALID = '1' then
                            WHICH_PERIPH_FUNC(S_AXI_ARADDR,
                                                PERIPH_BASE_ADDR,
                                                WHICH_PERIPH_RD,
                                                ADDR_ERR_RD);
                    PERIPH_VALID <= '1';
                end if;
            end if;
        end if;
    end process;

    -- Reset proc by ERR
    -- If read address is wrong, we force to reset the process, or ar_pending
    -- This reset only happend when ar_pending
    -- but read address is wrong
    -- only one pulse after data-address pending but false.
    
    ADDR_ERR_RD_CREATE_SIGNAL: process(S_AXI_ACLK)
    begin
        if rising_edge(S_AXI_ACLK) then
            if S_AXI_RESETN = '0' then
                RST_PROC_BY_ADDR_ERR_RD<= '0';
            else
                if RD_TRANSACTION_DONE = '1' then
                    RST_PROC_BY_ADDR_ERR_RD <= '0';
                elsif ADDR_ERR_RD = '1' and 
                AR_PENDING = '1' then
                    RST_PROC_BY_ADDR_ERR_RD <= '1';
                end if;
            end if;
        end if;
    end process;


    RD_FROM_PERIPH: process(S_AXI_ACLK)
    begin
        if rising_edge(S_AXI_ACLK) then
            if S_AXI_RESETN = '0' then
                for I in 0 to NUM_AXIL_MASTERS-1 loop
                    START_READ(I) <= '0';
                    RD_ADDR(I) <= x"DEADC0DE";
                end loop;
            else
                for I in 0 to NUM_AXIL_MASTERS-1 loop
                    START_READ(I) <= '0';
                end loop;

                if PERIPH_VALID = '1' and ADDR_ERR_RD = '0' then
                    START_READ(WHICH_PERIPH_RD) <= '1';
                    RD_ADDR(WHICH_PERIPH_RD) <= AXI_ARADDR;
                end if;
            end if;
        end if;
    end process;

    RECEIVED_DATA:process(S_AXI_ACLK)
    begin
        if rising_edge(S_AXI_ACLK) then
            if S_AXI_RESETN = '0' then
                AXI_RDATA <= (others => '0');
            else
                if RD_DATA_VALID(WHICH_PERIPH_RD) = '1' then
                    AXI_RDATA <= RD_DATA(WHICH_PERIPH_RD);
                elsif RST_PROC_BY_ADDR_ERR_RD = '1' then
                    AXI_RDATA <= (others => '0');
                end if;
            end if;
        end if;
    end process;

	READ_VALID_PROC: process(S_AXI_ACLK)
	begin
		if rising_edge(S_AXI_ACLK) then
			if (S_AXI_RESETN = '0') then
				AXI_RVALID <= '0';
			else
				if (RD_DATA_VALID(WHICH_PERIPH_RD) = '1'
                         and HOST_RD_DATA_READY(WHICH_PERIPH_RD) = '1') then
					AXI_RVALID <= '1';
				elsif RD_TRANSACTION_DONE = '1' then
					AXI_RVALID <= '0';
                -- Error case, still issue axi rvalid for rresp
                elsif RST_PROC_BY_ADDR_ERR_RD = '1' then
                    AXI_RVALID <= '1';
				end if;
			end if;
		end if;
	end process;

    -- At this moment, host CPU always ready to read data,
    -- Control read data thing will be left for software control.
    GEN_HOST_RD_READY:
    for I in 0 to NUM_AXIL_MASTERS-1 generate
        HOST_RD_DATA_READY(I) <= '1';
    end generate;

	RD_TRANSACTION_DONE <= '1' when S_AXI_RREADY = '1' 
                                    and AXI_RVALID = '1' 
                                    else '0';


    S_AXI_RDATA <= AXI_RDATA;

	--Simplification the S_AXI_RRESP
	S_AXI_RRESP <= AXIL_RRESP(WHICH_PERIPH_RD) when ADDR_ERR_RD /= '1' else "11";
	
    --------------------------------
end architecture;