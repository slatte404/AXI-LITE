
# 1. 接口与断言 (Interface & Assertions)
../tb/axiif/axi_lite_if.sv
../tb/assertion/axi_lite_assertions.sv

# 2. 设计文件 (Design Files)
../src/decoder.sv
../src/write_channel.sv
../src/read_channel.sv
../src/register_file.sv
../src/axi_top.sv

# 3. UVM Packages (核心！按依赖顺序编译)
# 注意：Package 内部已经包含了所有的 trans, driver, monitor 等文件，所以这里不需要再单独列出那些 .sv
../tb/env/axi_env_pkg.sv
../tb/sequences/axi_seq_pkg.sv
../tb/tests/axi_test_pkg.sv

# 4. 验证顶层 (Testbench Top)
../tb/top/tb_top.sv

# 5. 编译选项 (可选，如果 Makefile 里没写，可以在这里加)
+incdir+../tb/env
+incdir+../tb/sequences
+incdir+../tb/tests
