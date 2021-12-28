#!/bin/sh

# 
# Vivado(TM)
# runme.sh: a Vivado-generated Runs Script for UNIX
# Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
# 

echo "This script was generated under a different operating system."
echo "Please update the PATH and LD_LIBRARY_PATH variables below, before executing this script"
exit

if [ -z "$PATH" ]; then
  PATH=C:/Software/Xilinx/Vivado/2021.2/ids_lite/ISE/bin/nt64;C:/Software/Xilinx/Vivado/2021.2/ids_lite/ISE/lib/nt64:C:/Software/Xilinx/Vivado/2021.2/bin
else
  PATH=C:/Software/Xilinx/Vivado/2021.2/ids_lite/ISE/bin/nt64;C:/Software/Xilinx/Vivado/2021.2/ids_lite/ISE/lib/nt64:C:/Software/Xilinx/Vivado/2021.2/bin:$PATH
fi
export PATH

if [ -z "$LD_LIBRARY_PATH" ]; then
  LD_LIBRARY_PATH=
else
  LD_LIBRARY_PATH=:$LD_LIBRARY_PATH
fi
export LD_LIBRARY_PATH

HD_PWD='C:/Users/17289/OneDrive/Fall2021/ECE6463ADV_HARDWARE_DESIGN/RISC-V/milestone2/RISCV_v8/RISCV_v5.runs/synth_1'
cd "$HD_PWD"

HD_LOG=runme.log
/bin/touch $HD_LOG

ISEStep="./ISEWrap.sh"
EAStep()
{
     $ISEStep $HD_LOG "$@" >> $HD_LOG 2>&1
     if [ $? -ne 0 ]
     then
         exit
     fi
}

EAStep vivado -log processor_top.vds -m64 -product Vivado -mode batch -messageDb vivado.pb -notrace -source processor_top.tcl