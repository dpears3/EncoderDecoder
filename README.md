# EncoderDecoder
Project Assignment
CCED Project is to create CCED system which converts unencoded source data into encoded data and encoded data to decoded data on a FPGA for constraint lengths 3, 4, 5, 6, and 7
Source Computer sends and receives unencoded source data
Channel Computer sends and receives encoded data

Design Decisions
Used Nexys A7 FPGA to implement the hardware design, because the CCED has prior experience with this model from a previous course
SystemVerilog is the type of design file used because it allows preinitialize registers
Used Verilog as the programming language and Xilinx Vivado as the application
For the interface between encoder input from computers to the FPGA, we used RealTerm, because it is easier to input the data files than PuTTY and MobaXterm
