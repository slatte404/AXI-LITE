
# ==============================================================================
# AXI-Lite 自动化仿真 Makefile (洁癖版)
# ==============================================================================

# 默认参数
TEST     ?= axi_base_test
SEED     ?= 1
VERB     ?= UVM_MEDIUM
COV_DIR  ?= cov.vdb
OUT      ?= results

# 仿真列表 (用于回归)
TEST_LIST = axi_base_test axi_full_test axi_random_test axi_wraddr_test wstrb_test error_test

# ------------------------------------------------------------------------------
# 1. 编译 (Build)
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
# 2. 运行 (Run) - 在独立的子文件夹中运行
# ------------------------------------------------------------------------------
run:
	@mkdir -p $(OUT)/$(TEST)_$(SEED)
	@echo "Running $(TEST) with SEED=$(SEED) in $(OUT)/$(TEST)_$(SEED)..."
	@echo '#!/bin/bash' > $(OUT)/$(TEST)_$(SEED)/run_verdi.sh
	@echo 'cd ../../' >> $(OUT)/$(TEST)_$(SEED)/run_verdi.sh
	@echo 'verdi -ntb_opts uvm-1.2 -f filelist.f -ssf $(OUT)/$(TEST)_$(SEED)/tb.fsdb &' >> $(OUT)/$(TEST)_$(SEED)/run_verdi.sh
	@chmod +x $(OUT)/$(TEST)_$(SEED)/run_verdi.sh
	cd $(OUT)/$(TEST)_$(SEED) && \
	../../simv +UVM_TESTNAME=$(TEST) \
		+ntb_random_seed=$(SEED) \
		+UVM_VERBOSITY=$(VERB) \
		+vcs+assert+cov \
		-cm_dir ../../$(COV_DIR) \
		-cm_name $(TEST)_$(SEED) \
		-l sim.log

# ------------------------------------------------------------------------------
# 3. 回归测试 (Regression)
# ------------------------------------------------------------------------------
regr: build
	@echo "Starting Regression..."
	@for t in $(TEST_LIST); do \
		make run TEST=$$t SEED=$(SEED); \
	done
	@make cov

# ------------------------------------------------------------------------------
# 4. 其他工具
# ------------------------------------------------------------------------------
# 查看波形 (可以指定 TEST 和 SEED，默认打开 axi_base_test_1)
verdi:
	verdi -ntb_opts uvm-1.2 -f filelist.f -ssf $(OUT)/$(TEST)_$(SEED)/tb.fsdb &

# 合并覆盖率
cov:
	urg -full64 -dir $(COV_DIR) -report urgReport
	@echo "Coverage report generated in urgReport directory"

# 清理环境
clean:
	rm -rf *~ core csrc simv* vc_hdrs.h ucli.key urg* *.log novas.* *.fsdb* verdiLog 64* DVEfiles *.vpd $(COV_DIR) urgReport $(OUT)
