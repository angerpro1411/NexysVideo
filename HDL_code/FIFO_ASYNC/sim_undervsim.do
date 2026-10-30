vsim work.sim -voptargs=+acc
add wave -position insertpoint  \
sim:/sim/DATA_WIDTH \
sim:/sim/ADDR_WIDTH \
sim:/sim/WR_CLK \
sim:/sim/RD_CLK \
sim:/sim/ARSTN \
sim:/sim/WR_DATA \
sim:/sim/RD_DATA \
sim:/sim/WR \
sim:/sim/RD \
sim:/sim/RD_DATA_VALID \
sim:/sim/FULL \
sim:/sim/EMPTY \
sim:/sim/ALMOST_FULL \
sim:/sim/ALMOST_EMPTY \
sim:/sim/arr \
sim:/sim/d_o

add wave -position insertpoint  \
sim:/sim/fifo_test/mem/WR_CLK \
sim:/sim/fifo_test/mem/RD_CLK \
sim:/sim/fifo_test/mem/WR_ADDR \
sim:/sim/fifo_test/mem/RD_ADDR \
sim:/sim/fifo_test/mem/WR \
sim:/sim/fifo_test/mem/RD \
sim:/sim/fifo_test/mem/WR_DATA \
sim:/sim/fifo_test/mem/RD_DATA \
sim:/sim/fifo_test/mem/RAM

add wave -position insertpoint  \
sim:/sim/fifo_test/WR_CLK \
sim:/sim/fifo_test/RD_CLK \
sim:/sim/fifo_test/ARSTN \
sim:/sim/fifo_test/WR_DATA \
sim:/sim/fifo_test/RD_DATA \
sim:/sim/fifo_test/WR \
sim:/sim/fifo_test/RD \
sim:/sim/fifo_test/RD_DATA_VALID \
sim:/sim/fifo_test/FULL \
sim:/sim/fifo_test/EMPTY \
sim:/sim/fifo_test/ALMOST_FULL \
sim:/sim/fifo_test/ALMOST_EMPTY \
sim:/sim/fifo_test/WR_PTR \
sim:/sim/fifo_test/NX_WR_PTR \
sim:/sim/fifo_test/NX_RD_PTR \
sim:/sim/fifo_test/RD_PTR \
sim:/sim/fifo_test/NX_WR_PTR_GREY \
sim:/sim/fifo_test/NX_RD_PTR_GREY \
sim:/sim/fifo_test/WR_PTR_GREY \
sim:/sim/fifo_test/WR_PTR_GREY_UNDER_RD_CLK1 \
sim:/sim/fifo_test/WR_PTR_GREY_UNDER_RD_CLK2 \
sim:/sim/fifo_test/RD_PTR_GREY \
sim:/sim/fifo_test/RD_PTR_GREY_UNDER_WR_CLK1 \
sim:/sim/fifo_test/RD_PTR_GREY_UNDER_WR_CLK2 \
sim:/sim/fifo_test/SUCCESSFUL_WR \
sim:/sim/fifo_test/SUCCESSFUL_RD \
sim:/sim/fifo_test/FULL_CONDITION \
sim:/sim/fifo_test/NOT_FULL_CONDITION \
sim:/sim/fifo_test/OCCUPANCY_UNDER_WR_CLK \
sim:/sim/fifo_test/EMPTY_CONDITION \
sim:/sim/fifo_test/NOT_EMPTY_CONDITION \
sim:/sim/fifo_test/OCCUPANCY_UNDER_RD_CLK

run 500ns