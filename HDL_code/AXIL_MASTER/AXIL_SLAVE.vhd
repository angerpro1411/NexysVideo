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



entity AXIL_SLAVE is
	GENERIC(
		DATA_WIDTH		: integer := 32;
		STROBE_WIDTH	: integer := 32/8; -- datawidth / 4
	
		AXIL_ADDR_WIDTH : positive := 32;
		NUM_REGS        : positive := 4;
		
		
        -- Example-specific design signals
        -- local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
        -- ADDR_LSB is used for addressing 32/64 bit registers/memories
        -- ADDR_LSB = 2 for 32 bits address(n downto 2)
        -- ADDR_LSB = 3 for 64 bits address(n downto 3)		
		
		-- 4 configuration words, System 32-b byte addressable  
		-----------------------------------
		--|   8   |   8   |   8   |    8   |    => one word = 32 bits
		----------------------------------
		--With 32 bit data, we need 2-bits address(total 2^2 = 4 addresses) to addressing each 8 bit in one word 32 bits.
		--With 64 bit data, we need 3-bits address(total 2^3 = 8 addresses) to addressing each 8 bit in one word 64 bits.
		ADDRLSB			: integer := 2 -- log2(DATA_WIDTH) - 3	= log2(32) - 3 = 5-3 =2
	);
	PORT(
	    
	  --USER Input and Output
	    
	  ---------------------------------------------------------------------

    
		----------------------------Global signal----------------------------
		S_AXI_ACLK 		: in std_logic;
		S_AXI_ARESETN		: in std_logic;
		
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

architecture RTL of AXIL_SLAVE is

	--functions
	function APPLY_W_STRB(
		OLD_DATA : std_logic_vector(DATA_WIDTH-1 downto 0);
		NEW_DATA : std_logic_vector(DATA_WIDTH-1 downto 0);
		WRITE_STROBE : std_logic_vector(STROBE_WIDTH-1 downto 0)
	)	return std_logic_vector is
		
		variable TMP : std_logic_vector(DATA_WIDTH-1 downto 0);
		begin
			for I in 0 to STROBE_WIDTH-1 loop
				if (WRITE_STROBE(I) = '1') then
					TMP(8*(I+1)-1 downto 8*I) := NEW_DATA(8*(I+1)-1 downto 8*I);
				else 
					TMP(8*(I+1)-1 downto 8*I) := OLD_DATA(8*(I+1)-1 downto 8*I);
				end if;
			end loop;
				return TMP;
	end function APPLY_W_STRB;
	
	--use math_real library only for calculation generic and 
    --Correspond to number of registers.
    --For example, NUM_REGS = 4 bits, we lose 2 bit for addrlsb(byte-addressable), so we have 2 bits left for address register => 2^2 = 4 register.
    --As we always lose 2 bit for ADDRLSB with 32b system, if we want to have 32 registers => it means 5 bit address regis, so total 2+5=7 bit for address width
    constant NUM_BIT_4_REGS : integer := integer(ceil(log2(real(NUM_REGS))));
        
	
	type REG_ARR is array (0 to NUM_REGS-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
	signal AXI_SLAVE_R : REG_ARR;
	
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
    signal AXI_WDATA : std_logic_vector(DATA_WIDTH-1 downto 0);
	-- reg for storing write strobe at the same time with write data.
	signal AXI_WSTRB : std_logic_vector(STROBE_WIDTH-1 downto 0);
	
	signal AXI_RDATA : std_logic_vector(DATA_WIDTH-1 downto 0);
	
    -- User signals
    
begin

    --Connect buffers and outputs
    S_AXI_BVALID <= AXI_BVALID;
    S_AXI_AWREADY <= AXI_AWREADY;
    S_AXI_WREADY <= AXI_WREADY;
    S_AXI_ARREADY <= AXI_ARREADY;
    S_AXI_RVALID <= AXI_RVALID;
    

	-- WRITE ADDRESS process
	AW_READY_PROC: process(S_AXI_ACLK)
	begin
		if rising_edge(S_AXI_ACLK) then
			if (S_AXI_ARESETN = '0') then
				AXI_AWREADY <= '1';
				AW_PENDING <= '0';
			else
				if AXI_AWREADY = '1' and S_AXI_AWVALID = '1' then
					AXI_AWREADY <= '0';
					AW_PENDING <= '1';
				elsif WR_TO_SLAVE_REG_EN = '1' then
					AXI_AWREADY <= '1';
					AW_PENDING <= '0';
				end if;
			end if;
		end if;
	end process;

	AW_DATA_PROC: process(S_AXI_ACLK)
	begin
		if rising_edge(S_AXI_ACLK) then
			if (S_AXI_ARESETN = '0') then
				AXI_AWADDR <= (others => '0');
			else
				if AXI_AWREADY = '1' and S_AXI_AWVALID = '1' then
					AXI_AWADDR <= S_AXI_AWADDR;
				end if;
			end if;
		end if;
	end process;

	-- Write ready process
	W_READY_PROC: process(S_AXI_ACLK)
	begin
		if rising_edge(S_AXI_ACLK) then
			if (S_AXI_ARESETN = '0') then
				AXI_WREADY <= '1';
				WR_PENDING <= '0';
			else
				if AXI_WREADY = '1' and S_AXI_WVALID = '1' then
					AXI_WREADY <= '0';
					WR_PENDING <= '1';
				elsif WR_TO_SLAVE_REG_EN = '1' then
					AXI_WREADY <= '1';
					WR_PENDING <= '0';
				end if;
			end if;
		end if;
	end process;

	W_DATA_PROC: process(S_AXI_ACLK)
	begin
		if rising_edge(S_AXI_ACLK) then
			if (S_AXI_ARESETN = '0') then
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

	WR_TO_SLAVE_REG_EN <= '1' when (AW_PENDING = '1' and WR_PENDING = '1') else '0';

	WR_TO_SLAVE_REG : process(S_AXI_ACLK)
		variable LOC_ADDR : std_logic_vector(NUM_BIT_4_REGS-1 downto 0);
    begin
    	if rising_edge(S_AXI_ACLK) then
    		if S_AXI_ARESETN = '0' then
				for I in 0 to NUM_REGS-1 loop 
					AXI_SLAVE_R(I) <= (others => '0'); 			
				end loop;
			else
				LOC_ADDR := AXI_AWADDR(NUM_BIT_4_REGS+ADDRLSB-1 downto ADDRLSB);
				if WR_TO_SLAVE_REG_EN = '1' then
					AXI_SLAVE_R(to_integer(unsigned(LOC_ADDR))) <= 
								APPLY_W_STRB(AXI_SLAVE_R(to_integer(unsigned(LOC_ADDR))),AXI_WDATA,AXI_WSTRB);
				end if;
			end if;
		end if;					
    end process;

	-- Bvalid control for total write process
	B_VALID_PROC: process(S_AXI_ACLK)
    begin
    	if rising_edge(S_AXI_ACLK) then
    		if S_AXI_ARESETN = '0' then
				AXI_BVALID <= '0';
			else
				if WR_TO_SLAVE_REG_EN = '1' then
					AXI_BVALID <= '1';
				elsif AXI_BVALID = '1' and S_AXI_BREADY = '1' then
					AXI_BVALID <= '0';
				end if;
			end if;
		end if;		
	end process;

	--Simplify the BRESPONS
	S_AXI_BRESP <= "00";


	-- Read channel implementation
	AR_READY_PROC: process(S_AXI_ACLK)
	begin
		if rising_edge(S_AXI_ACLK) then
			if (S_AXI_ARESETN = '0') then
				AXI_ARREADY <= '1';
				AR_PENDING <= '0';
			else
				if AXI_ARREADY = '1' and S_AXI_ARVALID = '1' then
					AXI_ARREADY <= '0';
					AR_PENDING <= '1';
				elsif RD_TRANSACTION_DONE = '1' then
					AXI_ARREADY <= '1';
					AR_PENDING <= '0';
				end if;
			end if;
		end if;
	end process;

--	AR_DATA_PROC: process(S_AXI_ACLK)
--	begin
--		if rising_edge(S_AXI_ACLK) then
--			if (S_AXI_ARESETN = '0') then
--				AXI_ARADDR <= (others => '0');
--			else
--				if AXI_ARREADY = '1' and S_AXI_ARVALID = '1' then
--					AXI_ARADDR <= S_AXI_ARADDR;
--				end if;
--			end if;
--		end if;
--	end process;

	READ_VALID_PROC: process(S_AXI_ACLK)
	begin
		if rising_edge(S_AXI_ACLK) then
			if (S_AXI_ARESETN = '0') then
				AXI_RVALID <= '0';
			else
				if AXI_ARREADY = '1' and S_AXI_ARVALID = '1' then
					AXI_RVALID <= '1';
				elsif RD_TRANSACTION_DONE = '1' then
					AXI_RVALID <= '0';
				end if;
			end if;
		end if;
	end process;

	RD_TRANSACTION_DONE <= '1' when S_AXI_RREADY = '1' and AXI_RVALID = '1' else '0';

    READ_FROM_SLAVE_REG : process(S_AXI_ACLK)
    	variable LOC_ADDR : std_logic_vector(NUM_BIT_4_REGS-1 downto 0);
    begin
    	if rising_edge(S_AXI_ACLK) then
    		if S_AXI_ARESETN = '0' then
    			AXI_RDATA <= (others => '0');
			else
				LOC_ADDR := S_AXI_ARADDR(NUM_BIT_4_REGS+ADDRLSB-1 downto ADDRLSB);
				if AXI_ARREADY = '1' and S_AXI_ARVALID = '1' then
                    AXI_RDATA <= AXI_SLAVE_R(to_integer(unsigned(LOC_ADDR)));					
				end if;
			end if;
		end if;						    	
    end process;

    S_AXI_RDATA <= AXI_RDATA;

	--Simplification the S_AXI_RRESP
	S_AXI_RRESP <= "00";
	
    --------------------------------
end architecture;