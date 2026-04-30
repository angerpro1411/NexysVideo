# NexysVideo
All files and folder for Nexys Video FPGA

## Cannot stop MicroBlaze. MicroBlaze is held in reset
Nexys video doesn't have hard processor as Zynq, so we need to use soft processor - Microblaze.
And when I tried to run software program under Vitis unified, one problem happens even with hello world example. \
### Cannot stop MicroBlaze. MicroBlaze is held in reset
So I change in setting at MicroBlaze - select config from Current Setting to Microcontroller Prereset and It works.\
Reason : Maybe the config that reset and have the real connection hiding under the microblaze, so that fix clock, reset....


## Hanging problem when running build in Vivado :: Solution
https://askubuntu.com/questions/1553524/strange-taskbar-orange-icon
