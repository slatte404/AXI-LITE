
# 2. 设计文件
../src/decoder.sv
../src/write_channel.sv
../src/read_channel.sv
../src/register_file.sv
../src/axi_top.sv

../tb/axiif/axi_lite_if.sv
../tb/assertion/axi_lite_assertions.sv

../tb/env/axi_lite_trans.sv
../tb/env/axi_lite_sequencer.sv
../tb/env/axi_lite_driver.sv
../tb/env/axi_lite_monitor.sv
../tb/env/axi_lite_scoreboard.sv
../tb/env/axi_lite_coverage.sv
../tb/env/axi_lite_agent.sv
../tb/env/axi_lite_env.sv

../tb/sequences/axi_lite_seq.sv
../tb/sequences/axi_full_seq.sv
../tb/sequences/axi_wr_addr_seq.sv
../tb/sequences/axi_random_seq.sv

../tb/tests/axi_lite_test.sv
../tb/tests/full_test.sv
../tb/tests/wraddr_test.sv 
../tb/tests/random_test.sv

#../tb/env/axi_env_pkg.sv 
#../tb/sequences/axi_seq_pkg.sv 
#../tb/tests/axi_test_pkg.sv 
../tb/top/tb_top.sv

