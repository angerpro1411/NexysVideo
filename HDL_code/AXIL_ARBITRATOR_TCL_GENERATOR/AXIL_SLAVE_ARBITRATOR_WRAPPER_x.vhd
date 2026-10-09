
    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    entity AXIL_SLAVE_ARBITRATOR_WRAPPER is

        generic (
            DATA_WIDTH       : positive := 64;
            AXIL_ADDR_WIDTH  : positive := 32;
            PERIPH_BASE_ADDR : std_logic_vector(31 downto 0)
                            := x"30000000";
            AXIL_SLAVE_MAX_NUMB_REGISTERS : positive := 256
        );
    
        port (
            --------------------------------------------------------------------
            -- ================================================================
            -- AXI4-LITE SLAVE
            -- CPU / PS / MicroBlaze -> Arbitrator
            -- ================================================================
            --------------------------------------------------------------------

            -- Write address channel
            S_AXI_AWVALID : in  std_logic;
            S_AXI_AWREADY : out std_logic;
            S_AXI_AWADDR  : in  std_logic_vector(AXIL_ADDR_WIDTH-1 downto 0);

            -- Write data channel
            S_AXI_WVALID : in  std_logic;
            S_AXI_WREADY : out std_logic;
            S_AXI_WDATA  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            S_AXI_WSTRB  : in  std_logic_vector(DATA_WIDTH/8-1 downto 0);

            -- Write response channel
            S_AXI_BVALID : out std_logic;
            S_AXI_BREADY : in  std_logic;
            S_AXI_BRESP  : out std_logic_vector(1 downto 0);

            -- Read address channel
            S_AXI_ARVALID : in  std_logic;
            S_AXI_ARREADY : out std_logic;
            S_AXI_ARADDR  : in  std_logic_vector(AXIL_ADDR_WIDTH-1 downto 0);

            -- Read data channel
            S_AXI_RVALID : out std_logic;
            S_AXI_RREADY : in  std_logic;
            S_AXI_RDATA  : out std_logic_vector(DATA_WIDTH-1 downto 0);
            S_AXI_RRESP  : out std_logic_vector(1 downto 0);    
        
    
            --------------------------------------------------------------------
            -- ================================================================
            -- AXI4-LITE MASTER 0
            -- Arbitrator -> Peripheral 0
            -- ================================================================
            --------------------------------------------------------------------
            M0_AXI_AWVALID : out std_logic;
            M0_AXI_AWREADY : in  std_logic;
            M0_AXI_AWADDR  : out std_logic_vector(AXIL_ADDR_WIDTH-1 downto 0);

            M0_AXI_WVALID : out std_logic;
            M0_AXI_WREADY : in  std_logic;
            M0_AXI_WDATA  : out std_logic_vector(DATA_WIDTH-1 downto 0);
            M0_AXI_WSTRB  : out std_logic_vector(DATA_WIDTH/8-1 downto 0);

            M0_AXI_BVALID : in  std_logic;
            M0_AXI_BREADY : out std_logic;
            M0_AXI_BRESP  : in  std_logic_vector(1 downto 0);

            M0_AXI_ARVALID : out std_logic;
            M0_AXI_ARREADY : in  std_logic;
            M0_AXI_ARADDR  : out std_logic_vector(AXIL_ADDR_WIDTH-1 downto 0);

            M0_AXI_RVALID : in  std_logic;
            M0_AXI_RREADY : out std_logic;
            M0_AXI_RDATA  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            M0_AXI_RRESP  : in  std_logic_vector(1 downto 0);        
    
            --------------------------------------------------------------------
            -- ================================================================
            -- AXI4-LITE MASTER 1
            -- Arbitrator -> Peripheral 1
            -- ================================================================
            --------------------------------------------------------------------
            M1_AXI_AWVALID : out std_logic;
            M1_AXI_AWREADY : in  std_logic;
            M1_AXI_AWADDR  : out std_logic_vector(AXIL_ADDR_WIDTH-1 downto 0);

            M1_AXI_WVALID : out std_logic;
            M1_AXI_WREADY : in  std_logic;
            M1_AXI_WDATA  : out std_logic_vector(DATA_WIDTH-1 downto 0);
            M1_AXI_WSTRB  : out std_logic_vector(DATA_WIDTH/8-1 downto 0);

            M1_AXI_BVALID : in  std_logic;
            M1_AXI_BREADY : out std_logic;
            M1_AXI_BRESP  : in  std_logic_vector(1 downto 0);

            M1_AXI_ARVALID : out std_logic;
            M1_AXI_ARREADY : in  std_logic;
            M1_AXI_ARADDR  : out std_logic_vector(AXIL_ADDR_WIDTH-1 downto 0);

            M1_AXI_RVALID : in  std_logic;
            M1_AXI_RREADY : out std_logic;
            M1_AXI_RDATA  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            M1_AXI_RRESP  : in  std_logic_vector(1 downto 0);        
    
            --------------------------------------------------------------------
            -- ================================================================
            -- AXI4-LITE MASTER 2
            -- Arbitrator -> Peripheral 2
            -- ================================================================
            --------------------------------------------------------------------
            M2_AXI_AWVALID : out std_logic;
            M2_AXI_AWREADY : in  std_logic;
            M2_AXI_AWADDR  : out std_logic_vector(AXIL_ADDR_WIDTH-1 downto 0);

            M2_AXI_WVALID : out std_logic;
            M2_AXI_WREADY : in  std_logic;
            M2_AXI_WDATA  : out std_logic_vector(DATA_WIDTH-1 downto 0);
            M2_AXI_WSTRB  : out std_logic_vector(DATA_WIDTH/8-1 downto 0);

            M2_AXI_BVALID : in  std_logic;
            M2_AXI_BREADY : out std_logic;
            M2_AXI_BRESP  : in  std_logic_vector(1 downto 0);

            M2_AXI_ARVALID : out std_logic;
            M2_AXI_ARREADY : in  std_logic;
            M2_AXI_ARADDR  : out std_logic_vector(AXIL_ADDR_WIDTH-1 downto 0);

            M2_AXI_RVALID : in  std_logic;
            M2_AXI_RREADY : out std_logic;
            M2_AXI_RDATA  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            M2_AXI_RRESP  : in  std_logic_vector(1 downto 0);        
    
            --------------------------------------------------------------------
            -- ================================================================
            -- AXI4-LITE MASTER 3
            -- Arbitrator -> Peripheral 3
            -- ================================================================
            --------------------------------------------------------------------
            M3_AXI_AWVALID : out std_logic;
            M3_AXI_AWREADY : in  std_logic;
            M3_AXI_AWADDR  : out std_logic_vector(AXIL_ADDR_WIDTH-1 downto 0);

            M3_AXI_WVALID : out std_logic;
            M3_AXI_WREADY : in  std_logic;
            M3_AXI_WDATA  : out std_logic_vector(DATA_WIDTH-1 downto 0);
            M3_AXI_WSTRB  : out std_logic_vector(DATA_WIDTH/8-1 downto 0);

            M3_AXI_BVALID : in  std_logic;
            M3_AXI_BREADY : out std_logic;
            M3_AXI_BRESP  : in  std_logic_vector(1 downto 0);

            M3_AXI_ARVALID : out std_logic;
            M3_AXI_ARREADY : in  std_logic;
            M3_AXI_ARADDR  : out std_logic_vector(AXIL_ADDR_WIDTH-1 downto 0);

            M3_AXI_RVALID : in  std_logic;
            M3_AXI_RREADY : out std_logic;
            M3_AXI_RDATA  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            M3_AXI_RRESP  : in  std_logic_vector(1 downto 0);        
    
            --------------------------------------------------------------------
            -- ================================================================
            -- AXI4-LITE MASTER 4
            -- Arbitrator -> Peripheral 4
            -- ================================================================
            --------------------------------------------------------------------
            M4_AXI_AWVALID : out std_logic;
            M4_AXI_AWREADY : in  std_logic;
            M4_AXI_AWADDR  : out std_logic_vector(AXIL_ADDR_WIDTH-1 downto 0);

            M4_AXI_WVALID : out std_logic;
            M4_AXI_WREADY : in  std_logic;
            M4_AXI_WDATA  : out std_logic_vector(DATA_WIDTH-1 downto 0);
            M4_AXI_WSTRB  : out std_logic_vector(DATA_WIDTH/8-1 downto 0);

            M4_AXI_BVALID : in  std_logic;
            M4_AXI_BREADY : out std_logic;
            M4_AXI_BRESP  : in  std_logic_vector(1 downto 0);

            M4_AXI_ARVALID : out std_logic;
            M4_AXI_ARREADY : in  std_logic;
            M4_AXI_ARADDR  : out std_logic_vector(AXIL_ADDR_WIDTH-1 downto 0);

            M4_AXI_RVALID : in  std_logic;
            M4_AXI_RREADY : out std_logic;
            M4_AXI_RDATA  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            M4_AXI_RRESP  : in  std_logic_vector(1 downto 0);        
    
            --------------------------------------------------------------------
            -- ================================================================
            -- AXI4-LITE MASTER 5
            -- Arbitrator -> Peripheral 5
            -- ================================================================
            --------------------------------------------------------------------
            M5_AXI_AWVALID : out std_logic;
            M5_AXI_AWREADY : in  std_logic;
            M5_AXI_AWADDR  : out std_logic_vector(AXIL_ADDR_WIDTH-1 downto 0);

            M5_AXI_WVALID : out std_logic;
            M5_AXI_WREADY : in  std_logic;
            M5_AXI_WDATA  : out std_logic_vector(DATA_WIDTH-1 downto 0);
            M5_AXI_WSTRB  : out std_logic_vector(DATA_WIDTH/8-1 downto 0);

            M5_AXI_BVALID : in  std_logic;
            M5_AXI_BREADY : out std_logic;
            M5_AXI_BRESP  : in  std_logic_vector(1 downto 0);

            M5_AXI_ARVALID : out std_logic;
            M5_AXI_ARREADY : in  std_logic;
            M5_AXI_ARADDR  : out std_logic_vector(AXIL_ADDR_WIDTH-1 downto 0);

            M5_AXI_RVALID : in  std_logic;
            M5_AXI_RREADY : out std_logic;
            M5_AXI_RDATA  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            M5_AXI_RRESP  : in  std_logic_vector(1 downto 0);        
    
            --------------------------------------------------------------------
            -- ================================================================
            -- AXI4-LITE MASTER 6
            -- Arbitrator -> Peripheral 6
            -- ================================================================
            --------------------------------------------------------------------
            M6_AXI_AWVALID : out std_logic;
            M6_AXI_AWREADY : in  std_logic;
            M6_AXI_AWADDR  : out std_logic_vector(AXIL_ADDR_WIDTH-1 downto 0);

            M6_AXI_WVALID : out std_logic;
            M6_AXI_WREADY : in  std_logic;
            M6_AXI_WDATA  : out std_logic_vector(DATA_WIDTH-1 downto 0);
            M6_AXI_WSTRB  : out std_logic_vector(DATA_WIDTH/8-1 downto 0);

            M6_AXI_BVALID : in  std_logic;
            M6_AXI_BREADY : out std_logic;
            M6_AXI_BRESP  : in  std_logic_vector(1 downto 0);

            M6_AXI_ARVALID : out std_logic;
            M6_AXI_ARREADY : in  std_logic;
            M6_AXI_ARADDR  : out std_logic_vector(AXIL_ADDR_WIDTH-1 downto 0);

            M6_AXI_RVALID : in  std_logic;
            M6_AXI_RREADY : out std_logic;
            M6_AXI_RDATA  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            M6_AXI_RRESP  : in  std_logic_vector(1 downto 0);        
    
            --------------------------------------------------------------------
            -- ================================================================
            -- AXI4-LITE MASTER 7
            -- Arbitrator -> Peripheral 7
            -- ================================================================
            --------------------------------------------------------------------
            M7_AXI_AWVALID : out std_logic;
            M7_AXI_AWREADY : in  std_logic;
            M7_AXI_AWADDR  : out std_logic_vector(AXIL_ADDR_WIDTH-1 downto 0);

            M7_AXI_WVALID : out std_logic;
            M7_AXI_WREADY : in  std_logic;
            M7_AXI_WDATA  : out std_logic_vector(DATA_WIDTH-1 downto 0);
            M7_AXI_WSTRB  : out std_logic_vector(DATA_WIDTH/8-1 downto 0);

            M7_AXI_BVALID : in  std_logic;
            M7_AXI_BREADY : out std_logic;
            M7_AXI_BRESP  : in  std_logic_vector(1 downto 0);

            M7_AXI_ARVALID : out std_logic;
            M7_AXI_ARREADY : in  std_logic;
            M7_AXI_ARADDR  : out std_logic_vector(AXIL_ADDR_WIDTH-1 downto 0);

            M7_AXI_RVALID : in  std_logic;
            M7_AXI_RREADY : out std_logic;
            M7_AXI_RDATA  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            M7_AXI_RRESP  : in  std_logic_vector(1 downto 0);        
    
            --------------------------------------------------------------------
            -- Global AXI clock / reset
            --------------------------------------------------------------------
            S_AXI_ACLK  : in std_logic;
            S_AXI_RESETN : in std_logic
            );
    end entity;        
    
    architecture RTL of AXIL_SLAVE_ARBITRATOR_WRAPPER is


        constant NUM_AXIL_MASTERS : positive := 8;

        ------------------------------------------------------------------------
        -- Packed master signals required by AXIL_SLAVE_ARBITRATOR
        ------------------------------------------------------------------------

        signal m_axil_awvalid : std_logic_vector(NUM_AXIL_MASTERS-1 downto 0);
        signal m_axil_awaddr  : std_logic_vector(
            NUM_AXIL_MASTERS*AXIL_ADDR_WIDTH-1 downto 0
        );
        signal m_axil_awready : std_logic_vector(NUM_AXIL_MASTERS-1 downto 0);

        signal m_axil_wvalid : std_logic_vector(NUM_AXIL_MASTERS-1 downto 0);
        signal m_axil_wdata  : std_logic_vector(
            NUM_AXIL_MASTERS*DATA_WIDTH-1 downto 0
        );
        signal m_axil_wstrb : std_logic_vector(
            NUM_AXIL_MASTERS*(DATA_WIDTH/8)-1 downto 0
        );
        signal m_axil_wready : std_logic_vector(NUM_AXIL_MASTERS-1 downto 0);

        signal m_axil_bready : std_logic_vector(NUM_AXIL_MASTERS-1 downto 0);
        signal m_axil_bvalid : std_logic_vector(NUM_AXIL_MASTERS-1 downto 0);
        signal m_axil_bresp : std_logic_vector(
            NUM_AXIL_MASTERS*2-1 downto 0
        );

        signal m_axil_arvalid : std_logic_vector(NUM_AXIL_MASTERS-1 downto 0);
        signal m_axil_araddr : std_logic_vector(
            NUM_AXIL_MASTERS*AXIL_ADDR_WIDTH-1 downto 0
        );
        signal m_axil_arready : std_logic_vector(NUM_AXIL_MASTERS-1 downto 0);

        signal m_axil_rvalid : std_logic_vector(NUM_AXIL_MASTERS-1 downto 0);
        signal m_axil_rdata : std_logic_vector(
            NUM_AXIL_MASTERS*DATA_WIDTH-1 downto 0
        );
        signal m_axil_rready : std_logic_vector(NUM_AXIL_MASTERS-1 downto 0);
        signal m_axil_rresp : std_logic_vector(
            NUM_AXIL_MASTERS*2-1 downto 0
        );

    begin
    
        ------------------------------------------------------------------------
        -- ================================================================
        -- Instantiate arbitrator
        -- ================================================================
        ------------------------------------------------------------------------

        U_ARBITRATOR : entity work.AXIL_SLAVE_ARBITRATOR
            generic map (
                DATA_WIDTH        => DATA_WIDTH,
                STROBE_WIDTH      => DATA_WIDTH/8,
                AXIL_ADDR_WIDTH   => AXIL_ADDR_WIDTH,
                NUM_AXIL_MASTERS  => NUM_AXIL_MASTERS,
                PERIPH_BASE_ADDR  => PERIPH_BASE_ADDR,
                AXIL_SLAVE_MAX_NUMB_REGISTERS => AXIL_SLAVE_MAX_NUMB_REGISTERS
            )
            port map (

                ----------------------------------------------------------------
                -- Master interfaces
                ----------------------------------------------------------------

                M_AXIL_AWVALID => m_axil_awvalid,
                M_AXIL_AWADDR  => m_axil_awaddr,
                M_AXIL_AWREADY => m_axil_awready,

                M_AXIL_WVALID  => m_axil_wvalid,
                M_AXIL_WDATA   => m_axil_wdata,
                M_AXIL_WSTRB   => m_axil_wstrb,
                M_AXIL_WREADY  => m_axil_wready,

                M_AXIL_BREADY  => m_axil_bready,
                M_AXIL_BVALID  => m_axil_bvalid,
                M_AXIL_BRESP   => m_axil_bresp,

                M_AXIL_ARVALID => m_axil_arvalid,
                M_AXIL_ARADDR  => m_axil_araddr,
                M_AXIL_ARREADY => m_axil_arready,

                M_AXIL_RVALID  => m_axil_rvalid,
                M_AXIL_RDATA   => m_axil_rdata,
                M_AXIL_RREADY  => m_axil_rready,
                M_AXIL_RRESP   => m_axil_rresp,


                ----------------------------------------------------------------
                -- Slave interface
                ----------------------------------------------------------------

                S_AXI_ACLK    => S_AXI_ACLK,
                S_AXI_RESETN  => S_AXI_RESETN,

                S_AXI_AWVALID => S_AXI_AWVALID,
                S_AXI_AWREADY => S_AXI_AWREADY,
                S_AXI_AWADDR  => S_AXI_AWADDR,

                S_AXI_WDATA   => S_AXI_WDATA,
                S_AXI_WSTRB   => S_AXI_WSTRB,
                S_AXI_WVALID  => S_AXI_WVALID,
                S_AXI_WREADY  => S_AXI_WREADY,

                S_AXI_BREADY  => S_AXI_BREADY,
                S_AXI_BVALID  => S_AXI_BVALID,
                S_AXI_BRESP   => S_AXI_BRESP,

                S_AXI_ARADDR  => S_AXI_ARADDR,
                S_AXI_ARVALID => S_AXI_ARVALID,
                S_AXI_ARREADY => S_AXI_ARREADY,

                S_AXI_RDATA   => S_AXI_RDATA,
                S_AXI_RRESP   => S_AXI_RRESP,
                S_AXI_RVALID  => S_AXI_RVALID,
                S_AXI_RREADY  => S_AXI_RREADY
            );
    
        ------------------------------------------------------------------------
        -- ================================================================
        -- MASTER 0
        -- ================================================================
        ------------------------------------------------------------------------

        M0_AXI_AWVALID <= m_axil_awvalid(0);
        m_axil_awready(0) <= M0_AXI_AWREADY;
        M0_AXI_AWADDR <= m_axil_awaddr(
            (0+1)*AXIL_ADDR_WIDTH-1 downto 0*AXIL_ADDR_WIDTH
        );

        M0_AXI_WVALID <= m_axil_wvalid(0);
        m_axil_wready(0) <= M0_AXI_WREADY;
        M0_AXI_WDATA <= m_axil_wdata(
            (0+1)*DATA_WIDTH-1 downto 0*DATA_WIDTH
        );
        M0_AXI_WSTRB <= m_axil_wstrb(
            (0+1)*(DATA_WIDTH/8)-1 downto 0*(DATA_WIDTH/8)
        );

        M0_AXI_BREADY <= m_axil_bready(0);
        m_axil_bvalid(0) <= M0_AXI_BVALID;
        m_axil_bresp(2*(0+1)-1 downto 2*0) <= M0_AXI_BRESP;

        M0_AXI_ARVALID <= m_axil_arvalid(0);
        m_axil_arready(0) <= M0_AXI_ARREADY;
        M0_AXI_ARADDR <= m_axil_araddr(
            (0+1)*AXIL_ADDR_WIDTH-1 downto 0*AXIL_ADDR_WIDTH
        );

        m_axil_rvalid(0) <= M0_AXI_RVALID;
        M0_AXI_RREADY <= m_axil_rready(0);
        m_axil_rdata(
            (0+1)*DATA_WIDTH-1 downto 0*DATA_WIDTH) 
            <= M0_AXI_RDATA;
        m_axil_rresp(2*(0+1)-1 downto 2*0) <= M0_AXI_RRESP;
    
        ------------------------------------------------------------------------
        -- ================================================================
        -- MASTER 1
        -- ================================================================
        ------------------------------------------------------------------------

        M1_AXI_AWVALID <= m_axil_awvalid(1);
        m_axil_awready(1) <= M1_AXI_AWREADY;
        M1_AXI_AWADDR <= m_axil_awaddr(
            (1+1)*AXIL_ADDR_WIDTH-1 downto 1*AXIL_ADDR_WIDTH
        );

        M1_AXI_WVALID <= m_axil_wvalid(1);
        m_axil_wready(1) <= M1_AXI_WREADY;
        M1_AXI_WDATA <= m_axil_wdata(
            (1+1)*DATA_WIDTH-1 downto 1*DATA_WIDTH
        );
        M1_AXI_WSTRB <= m_axil_wstrb(
            (1+1)*(DATA_WIDTH/8)-1 downto 1*(DATA_WIDTH/8)
        );

        M1_AXI_BREADY <= m_axil_bready(1);
        m_axil_bvalid(1) <= M1_AXI_BVALID;
        m_axil_bresp(2*(1+1)-1 downto 2*1) <= M1_AXI_BRESP;

        M1_AXI_ARVALID <= m_axil_arvalid(1);
        m_axil_arready(1) <= M1_AXI_ARREADY;
        M1_AXI_ARADDR <= m_axil_araddr(
            (1+1)*AXIL_ADDR_WIDTH-1 downto 1*AXIL_ADDR_WIDTH
        );

        m_axil_rvalid(1) <= M1_AXI_RVALID;
        M1_AXI_RREADY <= m_axil_rready(1);
        m_axil_rdata(
            (1+1)*DATA_WIDTH-1 downto 1*DATA_WIDTH) 
            <= M1_AXI_RDATA;
        m_axil_rresp(2*(1+1)-1 downto 2*1) <= M1_AXI_RRESP;
    
        ------------------------------------------------------------------------
        -- ================================================================
        -- MASTER 2
        -- ================================================================
        ------------------------------------------------------------------------

        M2_AXI_AWVALID <= m_axil_awvalid(2);
        m_axil_awready(2) <= M2_AXI_AWREADY;
        M2_AXI_AWADDR <= m_axil_awaddr(
            (2+1)*AXIL_ADDR_WIDTH-1 downto 2*AXIL_ADDR_WIDTH
        );

        M2_AXI_WVALID <= m_axil_wvalid(2);
        m_axil_wready(2) <= M2_AXI_WREADY;
        M2_AXI_WDATA <= m_axil_wdata(
            (2+1)*DATA_WIDTH-1 downto 2*DATA_WIDTH
        );
        M2_AXI_WSTRB <= m_axil_wstrb(
            (2+1)*(DATA_WIDTH/8)-1 downto 2*(DATA_WIDTH/8)
        );

        M2_AXI_BREADY <= m_axil_bready(2);
        m_axil_bvalid(2) <= M2_AXI_BVALID;
        m_axil_bresp(2*(2+1)-1 downto 2*2) <= M2_AXI_BRESP;

        M2_AXI_ARVALID <= m_axil_arvalid(2);
        m_axil_arready(2) <= M2_AXI_ARREADY;
        M2_AXI_ARADDR <= m_axil_araddr(
            (2+1)*AXIL_ADDR_WIDTH-1 downto 2*AXIL_ADDR_WIDTH
        );

        m_axil_rvalid(2) <= M2_AXI_RVALID;
        M2_AXI_RREADY <= m_axil_rready(2);
        m_axil_rdata(
            (2+1)*DATA_WIDTH-1 downto 2*DATA_WIDTH) 
            <= M2_AXI_RDATA;
        m_axil_rresp(2*(2+1)-1 downto 2*2) <= M2_AXI_RRESP;
    
        ------------------------------------------------------------------------
        -- ================================================================
        -- MASTER 3
        -- ================================================================
        ------------------------------------------------------------------------

        M3_AXI_AWVALID <= m_axil_awvalid(3);
        m_axil_awready(3) <= M3_AXI_AWREADY;
        M3_AXI_AWADDR <= m_axil_awaddr(
            (3+1)*AXIL_ADDR_WIDTH-1 downto 3*AXIL_ADDR_WIDTH
        );

        M3_AXI_WVALID <= m_axil_wvalid(3);
        m_axil_wready(3) <= M3_AXI_WREADY;
        M3_AXI_WDATA <= m_axil_wdata(
            (3+1)*DATA_WIDTH-1 downto 3*DATA_WIDTH
        );
        M3_AXI_WSTRB <= m_axil_wstrb(
            (3+1)*(DATA_WIDTH/8)-1 downto 3*(DATA_WIDTH/8)
        );

        M3_AXI_BREADY <= m_axil_bready(3);
        m_axil_bvalid(3) <= M3_AXI_BVALID;
        m_axil_bresp(2*(3+1)-1 downto 2*3) <= M3_AXI_BRESP;

        M3_AXI_ARVALID <= m_axil_arvalid(3);
        m_axil_arready(3) <= M3_AXI_ARREADY;
        M3_AXI_ARADDR <= m_axil_araddr(
            (3+1)*AXIL_ADDR_WIDTH-1 downto 3*AXIL_ADDR_WIDTH
        );

        m_axil_rvalid(3) <= M3_AXI_RVALID;
        M3_AXI_RREADY <= m_axil_rready(3);
        m_axil_rdata(
            (3+1)*DATA_WIDTH-1 downto 3*DATA_WIDTH) 
            <= M3_AXI_RDATA;
        m_axil_rresp(2*(3+1)-1 downto 2*3) <= M3_AXI_RRESP;
    
        ------------------------------------------------------------------------
        -- ================================================================
        -- MASTER 4
        -- ================================================================
        ------------------------------------------------------------------------

        M4_AXI_AWVALID <= m_axil_awvalid(4);
        m_axil_awready(4) <= M4_AXI_AWREADY;
        M4_AXI_AWADDR <= m_axil_awaddr(
            (4+1)*AXIL_ADDR_WIDTH-1 downto 4*AXIL_ADDR_WIDTH
        );

        M4_AXI_WVALID <= m_axil_wvalid(4);
        m_axil_wready(4) <= M4_AXI_WREADY;
        M4_AXI_WDATA <= m_axil_wdata(
            (4+1)*DATA_WIDTH-1 downto 4*DATA_WIDTH
        );
        M4_AXI_WSTRB <= m_axil_wstrb(
            (4+1)*(DATA_WIDTH/8)-1 downto 4*(DATA_WIDTH/8)
        );

        M4_AXI_BREADY <= m_axil_bready(4);
        m_axil_bvalid(4) <= M4_AXI_BVALID;
        m_axil_bresp(2*(4+1)-1 downto 2*4) <= M4_AXI_BRESP;

        M4_AXI_ARVALID <= m_axil_arvalid(4);
        m_axil_arready(4) <= M4_AXI_ARREADY;
        M4_AXI_ARADDR <= m_axil_araddr(
            (4+1)*AXIL_ADDR_WIDTH-1 downto 4*AXIL_ADDR_WIDTH
        );

        m_axil_rvalid(4) <= M4_AXI_RVALID;
        M4_AXI_RREADY <= m_axil_rready(4);
        m_axil_rdata(
            (4+1)*DATA_WIDTH-1 downto 4*DATA_WIDTH) 
            <= M4_AXI_RDATA;
        m_axil_rresp(2*(4+1)-1 downto 2*4) <= M4_AXI_RRESP;
    
        ------------------------------------------------------------------------
        -- ================================================================
        -- MASTER 5
        -- ================================================================
        ------------------------------------------------------------------------

        M5_AXI_AWVALID <= m_axil_awvalid(5);
        m_axil_awready(5) <= M5_AXI_AWREADY;
        M5_AXI_AWADDR <= m_axil_awaddr(
            (5+1)*AXIL_ADDR_WIDTH-1 downto 5*AXIL_ADDR_WIDTH
        );

        M5_AXI_WVALID <= m_axil_wvalid(5);
        m_axil_wready(5) <= M5_AXI_WREADY;
        M5_AXI_WDATA <= m_axil_wdata(
            (5+1)*DATA_WIDTH-1 downto 5*DATA_WIDTH
        );
        M5_AXI_WSTRB <= m_axil_wstrb(
            (5+1)*(DATA_WIDTH/8)-1 downto 5*(DATA_WIDTH/8)
        );

        M5_AXI_BREADY <= m_axil_bready(5);
        m_axil_bvalid(5) <= M5_AXI_BVALID;
        m_axil_bresp(2*(5+1)-1 downto 2*5) <= M5_AXI_BRESP;

        M5_AXI_ARVALID <= m_axil_arvalid(5);
        m_axil_arready(5) <= M5_AXI_ARREADY;
        M5_AXI_ARADDR <= m_axil_araddr(
            (5+1)*AXIL_ADDR_WIDTH-1 downto 5*AXIL_ADDR_WIDTH
        );

        m_axil_rvalid(5) <= M5_AXI_RVALID;
        M5_AXI_RREADY <= m_axil_rready(5);
        m_axil_rdata(
            (5+1)*DATA_WIDTH-1 downto 5*DATA_WIDTH) 
            <= M5_AXI_RDATA;
        m_axil_rresp(2*(5+1)-1 downto 2*5) <= M5_AXI_RRESP;
    
        ------------------------------------------------------------------------
        -- ================================================================
        -- MASTER 6
        -- ================================================================
        ------------------------------------------------------------------------

        M6_AXI_AWVALID <= m_axil_awvalid(6);
        m_axil_awready(6) <= M6_AXI_AWREADY;
        M6_AXI_AWADDR <= m_axil_awaddr(
            (6+1)*AXIL_ADDR_WIDTH-1 downto 6*AXIL_ADDR_WIDTH
        );

        M6_AXI_WVALID <= m_axil_wvalid(6);
        m_axil_wready(6) <= M6_AXI_WREADY;
        M6_AXI_WDATA <= m_axil_wdata(
            (6+1)*DATA_WIDTH-1 downto 6*DATA_WIDTH
        );
        M6_AXI_WSTRB <= m_axil_wstrb(
            (6+1)*(DATA_WIDTH/8)-1 downto 6*(DATA_WIDTH/8)
        );

        M6_AXI_BREADY <= m_axil_bready(6);
        m_axil_bvalid(6) <= M6_AXI_BVALID;
        m_axil_bresp(2*(6+1)-1 downto 2*6) <= M6_AXI_BRESP;

        M6_AXI_ARVALID <= m_axil_arvalid(6);
        m_axil_arready(6) <= M6_AXI_ARREADY;
        M6_AXI_ARADDR <= m_axil_araddr(
            (6+1)*AXIL_ADDR_WIDTH-1 downto 6*AXIL_ADDR_WIDTH
        );

        m_axil_rvalid(6) <= M6_AXI_RVALID;
        M6_AXI_RREADY <= m_axil_rready(6);
        m_axil_rdata(
            (6+1)*DATA_WIDTH-1 downto 6*DATA_WIDTH) 
            <= M6_AXI_RDATA;
        m_axil_rresp(2*(6+1)-1 downto 2*6) <= M6_AXI_RRESP;
    
        ------------------------------------------------------------------------
        -- ================================================================
        -- MASTER 7
        -- ================================================================
        ------------------------------------------------------------------------

        M7_AXI_AWVALID <= m_axil_awvalid(7);
        m_axil_awready(7) <= M7_AXI_AWREADY;
        M7_AXI_AWADDR <= m_axil_awaddr(
            (7+1)*AXIL_ADDR_WIDTH-1 downto 7*AXIL_ADDR_WIDTH
        );

        M7_AXI_WVALID <= m_axil_wvalid(7);
        m_axil_wready(7) <= M7_AXI_WREADY;
        M7_AXI_WDATA <= m_axil_wdata(
            (7+1)*DATA_WIDTH-1 downto 7*DATA_WIDTH
        );
        M7_AXI_WSTRB <= m_axil_wstrb(
            (7+1)*(DATA_WIDTH/8)-1 downto 7*(DATA_WIDTH/8)
        );

        M7_AXI_BREADY <= m_axil_bready(7);
        m_axil_bvalid(7) <= M7_AXI_BVALID;
        m_axil_bresp(2*(7+1)-1 downto 2*7) <= M7_AXI_BRESP;

        M7_AXI_ARVALID <= m_axil_arvalid(7);
        m_axil_arready(7) <= M7_AXI_ARREADY;
        M7_AXI_ARADDR <= m_axil_araddr(
            (7+1)*AXIL_ADDR_WIDTH-1 downto 7*AXIL_ADDR_WIDTH
        );

        m_axil_rvalid(7) <= M7_AXI_RVALID;
        M7_AXI_RREADY <= m_axil_rready(7);
        m_axil_rdata(
            (7+1)*DATA_WIDTH-1 downto 7*DATA_WIDTH) 
            <= M7_AXI_RDATA;
        m_axil_rresp(2*(7+1)-1 downto 2*7) <= M7_AXI_RRESP;
    end architecture;
