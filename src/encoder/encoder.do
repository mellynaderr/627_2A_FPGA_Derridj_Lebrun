quit -sim

vlib work

vcom encoder.vhd
vcom encoder_tb.vhd

vsim -c work.encoder_tb

add wave -divider Inputs:
add wave -color green  uut/i_clk
add wave -color green  uut/i_rst_n
add wave -color green uut/s_en 
add wave -color blue   uut/i_a
add wave -color blue   uut/i_b

add wave -color white  uut/clockwise
add wave -color white  uut/cntclockwise 
# OUTPUTS
add wave -divider Outputs:
add wave -color red    uut/o_leds

run -all
