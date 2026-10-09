vsim work.top_test_master_slave -voptargs=+acc

add wave -position insertpoint  \
sim:/top_test_master_slave/START_WRITE \
sim:/top_test_master_slave/WR_ADDR \
sim:/top_test_master_slave/WR_DATA \
sim:/top_test_master_slave/WR_STRB \
sim:/top_test_master_slave/START_READ \
sim:/top_test_master_slave/RD_ADDR \
sim:/top_test_master_slave/RD_DATA \
sim:/top_test_master_slave/RD_DATA_VALID \
sim:/top_test_master_slave/HOST_RD_DATA_READY \
sim:/top_test_master_slave/WR_BUSY \
sim:/top_test_master_slave/ERR_WR \
sim:/top_test_master_slave/ERR_RD
add wave -position insertpoint  \
sim:/top_test_master_slave/MASTER_IP/M_AXIL_ACLK \
sim:/top_test_master_slave/MASTER_IP/M_AXIL_RSTN \
sim:/top_test_master_slave/MASTER_IP/M_AXIL_AWVALID \
sim:/top_test_master_slave/MASTER_IP/M_AXIL_AWADDR \
sim:/top_test_master_slave/MASTER_IP/M_AXIL_AWREADY \
sim:/top_test_master_slave/MASTER_IP/M_AXIL_WVALID \
sim:/top_test_master_slave/MASTER_IP/M_AXIL_WDATA \
sim:/top_test_master_slave/MASTER_IP/M_AXIL_WSTRB \
sim:/top_test_master_slave/MASTER_IP/M_AXIL_WREADY \
sim:/top_test_master_slave/MASTER_IP/M_AXIL_BREADY \
sim:/top_test_master_slave/MASTER_IP/M_AXIL_BVALID \
sim:/top_test_master_slave/MASTER_IP/M_AXIL_BRESP \
sim:/top_test_master_slave/MASTER_IP/M_AXIL_ARVALID \
sim:/top_test_master_slave/MASTER_IP/M_AXIL_ARADDR \
sim:/top_test_master_slave/MASTER_IP/M_AXIL_ARREADY \
sim:/top_test_master_slave/MASTER_IP/M_AXIL_RVALID \
sim:/top_test_master_slave/MASTER_IP/M_AXIL_RDATA \
sim:/top_test_master_slave/MASTER_IP/M_AXIL_RREADY \
sim:/top_test_master_slave/MASTER_IP/M_AXIL_RRESP
add wave -position insertpoint  \
sim:/top_test_master_slave/SLAVE_IP/S_AXI_ACLK \
sim:/top_test_master_slave/SLAVE_IP/S_AXI_ARESETN \
sim:/top_test_master_slave/SLAVE_IP/S_AXI_AWVALID \
sim:/top_test_master_slave/SLAVE_IP/S_AXI_AWREADY \
sim:/top_test_master_slave/SLAVE_IP/S_AXI_AWADDR \
sim:/top_test_master_slave/SLAVE_IP/S_AXI_WDATA \
sim:/top_test_master_slave/SLAVE_IP/S_AXI_WSTRB \
sim:/top_test_master_slave/SLAVE_IP/S_AXI_WVALID \
sim:/top_test_master_slave/SLAVE_IP/S_AXI_WREADY \
sim:/top_test_master_slave/SLAVE_IP/S_AXI_BREADY \
sim:/top_test_master_slave/SLAVE_IP/S_AXI_BVALID \
sim:/top_test_master_slave/SLAVE_IP/S_AXI_BRESP \
sim:/top_test_master_slave/SLAVE_IP/S_AXI_ARADDR \
sim:/top_test_master_slave/SLAVE_IP/S_AXI_ARVALID \
sim:/top_test_master_slave/SLAVE_IP/S_AXI_ARREADY \
sim:/top_test_master_slave/SLAVE_IP/S_AXI_RDATA \
sim:/top_test_master_slave/SLAVE_IP/S_AXI_RRESP \
sim:/top_test_master_slave/SLAVE_IP/S_AXI_RVALID \
sim:/top_test_master_slave/SLAVE_IP/S_AXI_RREADY

add wave -position insertpoint  \
sim:/top_test_master_slave/SLAVE_IP/AXI_SLAVE_R

run 1us