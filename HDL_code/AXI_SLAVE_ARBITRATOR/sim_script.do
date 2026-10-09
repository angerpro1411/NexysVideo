add wave -position insertpoint sim:/top_test/*
add wave -position insertpoint {sim:/top_test/AXIL_BUS_DOWNSTREAM[0]/*}
add wave -position insertpoint {sim:/top_test/AXIL_BUS_DOWNSTREAM[1]/*}
add wave -position insertpoint {sim:/top_test/AXIL_BUS_DOWNSTREAM[2]/*}
add wave -position insertpoint {sim:/top_test/AXIL_BUS_DOWNSTREAM[3]/*}
add wave -position insertpoint sim:/top_test/AXIL_BUS_UPSTREAM/*
add wave -position insertpoint  \
{sim:/top_test/GEN_AXIL_SLAVE[3]/AXIL_SLAVE_INST/AXIL_SLAVE/AXI_SLAVE_R}
add wave -position insertpoint  \
{sim:/top_test/GEN_AXIL_SLAVE[2]/AXIL_SLAVE_INST/AXIL_SLAVE/AXI_SLAVE_R}
add wave -position insertpoint  \
{sim:/top_test/GEN_AXIL_SLAVE[1]/AXIL_SLAVE_INST/AXIL_SLAVE/AXI_SLAVE_R}
add wave -position insertpoint  \
{sim:/top_test/GEN_AXIL_SLAVE[0]/AXIL_SLAVE_INST/AXIL_SLAVE/AXI_SLAVE_R}
run 1us