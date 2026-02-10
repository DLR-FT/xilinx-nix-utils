set_property PACKAGE_PIN H14 [get_ports UART_txd]
set_property PACKAGE_PIN H13 [get_ports UART_rxd]
set_property PACKAGE_PIN J15 [get_ports UART_ctsn]
set_property PACKAGE_PIN J14 [get_ports UART_rtsn]
set_property PACKAGE_PIN K15 [get_ports UART_dsrn]
set_property PACKAGE_PIN L15 [get_ports UART_dtrn]
#NC: UART_0_dcdn, UART_0_ri
set_property PACKAGE_PIN L14 [get_ports UART_dcdn]
set_property PACKAGE_PIN M15 [get_ports UART_ri]
set_property IOSTANDARD LVCMOS33 [get_ports UART_*]

set_property PACKAGE_PIN P13 [get_ports IIC_scl_io]
set_property PACKAGE_PIN R13 [get_ports IIC_sda_io]
set_property IOSTANDARD LVCMOS33 [get_ports IIC_*]

#set_property PACKAGE_PIN G14 [get_ports LED_tri_o]
#set_property IOSTANDARD LVCMOS33 [get_ports LED_*]
