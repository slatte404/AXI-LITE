
# ==============================================================================
# AXI-Lite 自动化仿真 Makefile
# ==============================================================================

# 默认参数（可以在命令行修改，例如: make run TEST=random_test SEED=123）
TEST     ?= axi_base_test
SEED     ?= 1
VERB     ?= UVM_MEDIUM
COV_DIR  ?= cov.vdb

# 仿真列表（用于一键回归）
TEST_LIST = axi_base_test axi_full_test axi_random_test axi_wraddr_test

# ------------------------------------------------------------------------------
# 1. 编译 (Build) - 只有代码变动时才需要跑一次
# ------------------------------------------------------------------------------
build:
	vcs -f filelist.f \
		-timescale=1ns/1ps \
		-ntb_opts uvm-1.2 \
		-lca -full64 -sverilog -debug_access+all \
		-cm line+cond+fsm+tgl+branch+assert \
		-cm_dir $(COV_DIR) \
		-o simv \
		-l compile.log

# ------------------------------------------------------------------------------
# 2. 运行 (Run) - 编译一次后，可以无限次跑不同的测试
# ------------------------------------------------------------------------------
run:
	./simv +UVM_TESTNAME=$(TEST) \
		+ntb_random_seed=$(SEED) \
		+UVM_VERBOSITY=$(VERB) \
		+vcs+assert+cov \
		-cm_dir $(COV_DIR) \
		-cm_append \
		-l $(TEST)_$(SEED).log

# ------------------------------------------------------------------------------
# 3. 回归测试 (Regression) - 一键跑完所有用例
# ------------------------------------------------------------------------------
regr: build
	@echo "Starting Regression..."
	@for t in $(TEST_LIST); do \
		echo "Running test: $$t"; \
		./simv +UVM_TESTNAME=$$t +ntb_random_seed=$(SEED) -cm_dir $(COV_DIR) -cm_append -l $$t.log; \
	done
	@make cov

# ------------------------------------------------------------------------------
# 4. 其他工具
# ------------------------------------------------------------------------------
# 查看波形
verdi:
	verdi -ntb_opts uvm-1.2 -f filelist.f -ssf tb.fsdb &

# 合并覆盖率并查看报告
cov:
	urg -full64 -dir $(COV_DIR) -report urgReport
	@echo "Coverage report generated in urgReport directory"

# 清理环境
clean:
	rm -rf *~ core csrc simv* vc_hdrs.h ucli.key urg* *.log novas.* *.fsdb* verdiLog 64* DVEfiles *.vpd $(COV_DIR) urgReport
