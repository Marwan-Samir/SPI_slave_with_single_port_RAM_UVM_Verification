vlib work
vlog -f src_files.list  +define+SIM +cover -covercells +cover -covercells
vsim -voptargs=+acc work.wrapper_top -cover -classdebug -uvmcontrol=all
add wave /wrapper_top/dut/*
coverage save wrapper_top_Cover.ucdb -onexit
vcover report wrapper_top_cover.ucdb -details -annotate -all -output cvr.txt
run -all