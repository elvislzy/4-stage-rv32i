set_property DONT_TOUCH true [get_cells alu]
set_property DONT_TOUCH true [get_cells ALU_control]
set_property DONT_TOUCH true [get_cells Control_unit]
set_property DONT_TOUCH true [get_cells data_ext_MEM]
set_property DONT_TOUCH true [get_cells data_mem]
set_property DONT_TOUCH true [get_cells imm_gen]
set_property DONT_TOUCH true [get_cells instr_mem]
set_property DONT_TOUCH true [get_cells PC]
set_property DONT_TOUCH true [get_cells pc_adder]
set_property DONT_TOUCH true [get_cells regfile]

create_clock -period 12.000 -name clk -waveform {0.000 6.000} [get_ports -filter { NAME =~  "*clk*" && DIRECTION == "IN" }]


