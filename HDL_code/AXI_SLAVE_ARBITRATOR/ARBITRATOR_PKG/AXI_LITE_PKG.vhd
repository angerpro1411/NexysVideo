library ieee;
use ieee.std_logic_1164.all;

package AXI_LITE_PKG is

    constant DATA_WIDTH		: integer := 32;
    constant AXIL_ADDR_WIDTH : positive := 32;

    -- Master -> Slave signals
    type AXIL_M2S_t is record
        AWVALID :  std_logic;
        AWADDR  :  std_logic_vector(AXIL_ADDR_WIDTH-1 downto 0);

        WVALID :  std_logic;
        WDATA  :  std_logic_vector(DATA_WIDTH-1 downto 0);
        WSTRB  :  std_logic_vector(DATA_WIDTH/8-1 downto 0);     
        
        
        BREADY :  std_logic;

        ARVALID :  std_logic;
        ARADDR  :  std_logic_vector(AXIL_ADDR_WIDTH-1 downto 0);

        RREADY :  std_logic;
    end record;

    type AXIL_S2M_t is record
        AWREADY :  std_logic;
        WREADY :  std_logic;

        BVALID :  std_logic;
        BRESP  :  std_logic_vector(1 downto 0);     
        
        ARREADY :  std_logic;
        RVALID :  std_logic;
        RDATA  :  std_logic_vector(DATA_WIDTH-1 downto 0);
        
        RRESP  :  std_logic_vector(1 downto 0);            
    end record;

    -- Arrays of interfaces
    type AXIL_M2S_ARRAY_t is array (natural range <>) of AXIL_M2S_t;

    type AXIL_S2M_ARRAY_t is array (natural range <>) of AXIL_S2M_t;

end package;