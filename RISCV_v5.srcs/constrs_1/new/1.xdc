set_property DONT_TOUCH true [get_cells alu]
set_property DONT_TOUCH true [get_cells alu_ctrl]
set_property DONT_TOUCH true [get_cells processor_ctrl]
set_property DONT_TOUCH true [get_cells data_ext]
set_property DONT_TOUCH true [get_cells data_mem]
set_property DONT_TOUCH true [get_cells imm_gen]
set_property DONT_TOUCH true [get_cells instr_mem]
set_property DONT_TOUCH true [get_cells PC]
set_property DONT_TOUCH true [get_cells regfile]

create_clock -period 6.000 -name clk -waveform {0.000 3.000} [get_ports -filter { NAME =~  "*clk*" && DIRECTION == "IN" }]







