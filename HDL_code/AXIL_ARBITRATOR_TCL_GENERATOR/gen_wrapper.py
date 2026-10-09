#!/usr/bin/env python3

import argparse
from pathlib import Path

#generic value
DATA_WIDTH = 32
AXIL_ADDR_WIDTH = 32
PERIPH_BASE_ADDR = 'x"30000000"'
AXIL_SLAVE_MAX_NUMB_REGISTERS = 256

def gen_wrapper(num_masters, output_file):
    vhdl_header = """
    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    """

    entity = "entity AXIL_SLAVE_ARBITRATOR_WRAPPER is\n"

    generic = f"""
        generic (
            DATA_WIDTH       : positive := {DATA_WIDTH};
            AXIL_ADDR_WIDTH  : positive := {AXIL_ADDR_WIDTH};
            PERIPH_BASE_ADDR : std_logic_vector(31 downto 0)
                            := {PERIPH_BASE_ADDR};
            AXIL_SLAVE_MAX_NUMB_REGISTERS : positive := {AXIL_SLAVE_MAX_NUMB_REGISTERS}
        );
    """

    port_slave = """
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
        
    """
    port_master=""
    for i in range(num_masters):
        port_master += f"""
            --------------------------------------------------------------------
            -- ================================================================
            -- AXI4-LITE MASTER {i}
            -- Arbitrator -> Peripheral {i}
            -- ================================================================
            --------------------------------------------------------------------
            M{i}_AXI_AWVALID : out std_logic;
            M{i}_AXI_AWREADY : in  std_logic;
            M{i}_AXI_AWADDR  : out std_logic_vector(AXIL_ADDR_WIDTH-1 downto 0);

            M{i}_AXI_WVALID : out std_logic;
            M{i}_AXI_WREADY : in  std_logic;
            M{i}_AXI_WDATA  : out std_logic_vector(DATA_WIDTH-1 downto 0);
            M{i}_AXI_WSTRB  : out std_logic_vector(DATA_WIDTH/8-1 downto 0);

            M{i}_AXI_BVALID : in  std_logic;
            M{i}_AXI_BREADY : out std_logic;
            M{i}_AXI_BRESP  : in  std_logic_vector(1 downto 0);

            M{i}_AXI_ARVALID : out std_logic;
            M{i}_AXI_ARREADY : in  std_logic;
            M{i}_AXI_ARADDR  : out std_logic_vector(AXIL_ADDR_WIDTH-1 downto 0);

            M{i}_AXI_RVALID : in  std_logic;
            M{i}_AXI_RREADY : out std_logic;
            M{i}_AXI_RDATA  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            M{i}_AXI_RRESP  : in  std_logic_vector(1 downto 0);        
    """

    clk_n_rst = """
            --------------------------------------------------------------------
            -- Global AXI clock / reset
            --------------------------------------------------------------------
            S_AXI_ACLK  : in std_logic;
            S_AXI_RESETN : in std_logic
            );
    end entity;        
    """

    archi_2_begin = f"""
    architecture RTL of AXIL_SLAVE_ARBITRATOR_WRAPPER is


        constant NUM_AXIL_MASTERS : positive := {num_masters};

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
    """

    instantiation="""
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
    """

    assign_signal=""
    for i in range(num_masters):
        assign_signal+= f"""
        ------------------------------------------------------------------------
        -- ================================================================
        -- MASTER {i}
        -- ================================================================
        ------------------------------------------------------------------------

        M{i}_AXI_AWVALID <= m_axil_awvalid({i});
        m_axil_awready({i}) <= M{i}_AXI_AWREADY;
        M{i}_AXI_AWADDR <= m_axil_awaddr(
            ({i}+1)*AXIL_ADDR_WIDTH-1 downto {i}*AXIL_ADDR_WIDTH
        );

        M{i}_AXI_WVALID <= m_axil_wvalid({i});
        m_axil_wready({i}) <= M{i}_AXI_WREADY;
        M{i}_AXI_WDATA <= m_axil_wdata(
            ({i}+1)*DATA_WIDTH-1 downto {i}*DATA_WIDTH
        );
        M{i}_AXI_WSTRB <= m_axil_wstrb(
            ({i}+1)*(DATA_WIDTH/8)-1 downto {i}*(DATA_WIDTH/8)
        );

        M{i}_AXI_BREADY <= m_axil_bready({i});
        m_axil_bvalid({i}) <= M{i}_AXI_BVALID;
        m_axil_bresp(2*({i}+1)-1 downto 2*{i}) <= M{i}_AXI_BRESP;

        M{i}_AXI_ARVALID <= m_axil_arvalid({i});
        m_axil_arready({i}) <= M{i}_AXI_ARREADY;
        M{i}_AXI_ARADDR <= m_axil_araddr(
            ({i}+1)*AXIL_ADDR_WIDTH-1 downto {i}*AXIL_ADDR_WIDTH
        );

        m_axil_rvalid({i}) <= M{i}_AXI_RVALID;
        M{i}_AXI_RREADY <= m_axil_rready({i});
        m_axil_rdata(
            ({i}+1)*DATA_WIDTH-1 downto {i}*DATA_WIDTH) 
            <= M{i}_AXI_RDATA;
        m_axil_rresp(2*({i}+1)-1 downto 2*{i}) <= M{i}_AXI_RRESP;
    """

    end_ar = 'end architecture;'




    if num_masters < 1:
        raise ValueError("Master numbers must be >= 1")

    output = vhdl_header
    output+=entity
    output+=generic
    output+=port_slave
    output+=port_master
    output+=clk_n_rst
    output+=archi_2_begin
    output+=instantiation
    output+=assign_signal
    output+=end_ar + "\n"

    Path(output_file).write_text(output,encoding="utf-8")

    print(f"Generated a wrapper with {num_masters} masters: at {output_file}")

def main():

    global DATA_WIDTH
    global AXIL_ADDR_WIDTH
    global PERIPH_BASE_ADDR
    global AXIL_SLAVE_MAX_NUMB_REGISTERS


    parser = argparse.ArgumentParser(
        description="Generate an AXI-Lite arbitrator wrapper"
    )

    parser.add_argument(
        "--masters",
        type=int,
        required=True,
        help="Number of AXIL master interfaces"
    )

    parser.add_argument(
        "--output",
        default="AXIL_SLAVE_ARBITRATOR_WRAPPER_x.vhd",
        help="Output VHDL file name"
    )

    parser.add_argument(
        "--data_width",
        type=int,
        default=DATA_WIDTH,
        help="Data Width"
    )

    parser.add_argument(
        "--addr_width",
        type=int,
        default=AXIL_ADDR_WIDTH,
        help="Address width"
    )

    parser.add_argument(
        "--base_addr",
        default=PERIPH_BASE_ADDR,
        help="Base address of first axil slave"
    )

    parser.add_argument(
        "--max_regs",
        type=int,
        default=AXIL_SLAVE_MAX_NUMB_REGISTERS,
        help="Maximum number regs for each axil slave periph"
    )

    args = parser.parse_args()



    DATA_WIDTH = args.data_width
    AXIL_ADDR_WIDTH = args.addr_width
    PERIPH_BASE_ADDR = args.base_addr
    AXIL_SLAVE_MAX_NUMB_REGISTERS = args.max_regs

    gen_wrapper(args.masters, args.output)

if __name__ == "__main__":
    main()



