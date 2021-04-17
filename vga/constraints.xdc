#// Clock on E3
set_property PACKAGE_PIN E3 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

#// Rest Signal
set_property PACKAGE_PIN N17 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports reset]

#// VGA Port
set_property PACKAGE_PIN D8 [get_ports {VGA_B[3]}]
set_property PACKAGE_PIN D7 [get_ports {VGA_B[2]}]
set_property PACKAGE_PIN C7 [get_ports {VGA_B[1]}]
set_property PACKAGE_PIN B7 [get_ports {VGA_B[0]}]
set_property PACKAGE_PIN A6 [get_ports {VGA_G[3]}]
set_property PACKAGE_PIN B6 [get_ports {VGA_G[2]}]
set_property PACKAGE_PIN A5 [get_ports {VGA_G[1]}]
set_property PACKAGE_PIN C6 [get_ports {VGA_G[0]}]
set_property PACKAGE_PIN A4 [get_ports {VGA_R[3]}]
set_property PACKAGE_PIN C5 [get_ports {VGA_R[2]}]
set_property PACKAGE_PIN B4 [get_ports {VGA_R[1]}]
set_property PACKAGE_PIN A3 [get_ports {VGA_R[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_B[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_B[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_B[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_B[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_G[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_G[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_G[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_G[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_R[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_R[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_R[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_R[0]}]

#// Sync Ports
set_property PACKAGE_PIN B11 [get_ports hSync]
set_property PACKAGE_PIN B12 [get_ports vSync]
set_property IOSTANDARD LVCMOS33 [get_ports hSync]
set_property IOSTANDARD LVCMOS33 [get_ports vSync]

#// PS2 Stuff
set_property PACKAGE_PIN F4 [get_ports ps2_clk]
set_property PACKAGE_PIN B2 [get_ports ps2_data]
set_property IOSTANDARD LVCMOS33 [get_ports ps2_clk]
set_property IOSTANDARD LVCMOS33 [get_ports ps2_data]


#set_property PACKAGE_PIN U11 [get_ports down]
#set_property PACKAGE_PIN L16 [get_ports left]
#set_property PACKAGE_PIN J15 [get_ports right]
#set_property PACKAGE_PIN V10 [get_ports up]
#set_property IOSTANDARD LVCMOS33 [get_ports down]
#set_property IOSTANDARD LVCMOS33 [get_ports left]
#set_property IOSTANDARD LVCMOS33 [get_ports right]
#set_property IOSTANDARD LVCMOS33 [get_ports up]

set_property IOSTANDARD LVCMOS33 [get_ports p1_up]
set_property IOSTANDARD LVCMOS33 [get_ports p1_right]
set_property IOSTANDARD LVCMOS33 [get_ports p1_left]
set_property IOSTANDARD LVCMOS33 [get_ports p1_down]
set_property IOSTANDARD LVCMOS33 [get_ports p2_down]
set_property IOSTANDARD LVCMOS33 [get_ports p2_left]
set_property IOSTANDARD LVCMOS33 [get_ports p2_right]
set_property IOSTANDARD LVCMOS33 [get_ports p2_up]
set_property PACKAGE_PIN V10 [get_ports p1_up]
set_property PACKAGE_PIN U11 [get_ports p1_down]
set_property PACKAGE_PIN U12 [get_ports p1_left]
set_property PACKAGE_PIN H6 [get_ports p1_right]
set_property PACKAGE_PIN U8 [get_ports p2_up]
set_property PACKAGE_PIN T8 [get_ports p2_down]
set_property PACKAGE_PIN R13 [get_ports p2_left]
set_property PACKAGE_PIN U18 [get_ports p2_right]

set_property IOSTANDARD LVCMOS33 [get_ports p2_cross]
set_property PACKAGE_PIN V11 [get_ports p2_cross]


set_property IOSTANDARD LVCMOS33 [get_ports ca]
set_property IOSTANDARD LVCMOS33 [get_ports cb]
set_property IOSTANDARD LVCMOS33 [get_ports cc]
set_property IOSTANDARD LVCMOS33 [get_ports cd]
set_property IOSTANDARD LVCMOS33 [get_ports ce]
set_property IOSTANDARD LVCMOS33 [get_ports cf]
set_property IOSTANDARD LVCMOS33 [get_ports cg]
set_property PACKAGE_PIN T10 [get_ports ca]
set_property PACKAGE_PIN R10 [get_ports cb]
set_property PACKAGE_PIN K16 [get_ports cc]
set_property PACKAGE_PIN K13 [get_ports cd]
set_property PACKAGE_PIN P15 [get_ports ce]
set_property PACKAGE_PIN T11 [get_ports cf]
set_property PACKAGE_PIN L18 [get_ports cg]
