
#-------------------------------------------------------------------------------------------------------
comp  : clean vcs
#-------------------------------------------------------------------------------------------------------
build:
	vcs -f filelist.f \
		-timescale=1ns/1ps \
		-ntb_opts uvm-1.2 \
		-lca -full64 -sverilog -debug_access+all \
		-cm line+cond+fsm+tgl+branch+assert \
		-cm_dir ./cov.vdb \
		-o simv \
		-l compile.log

vcs: build
	./simv +UVM_TESTNAME=$(TEST) \
		+vcs+assert+cov \
		-cm_dir ./cov.vdb \
		-cm_append
		-l sim.log

#-------------------------------------------------------------------------------------------------------
verdi  :
	verdi -ntb_opts uvm-1.2 \
		  -f filelist.f -ssf tb.fsdb &
#-------------------------------------------------------------------------------------------------------
clean  :
	rm -rf *~ core csrc simv* vc_hdrs.h ucli.key urg* *.log novas.* *.fsdb* verdiLog 64* DVEfiles *.vpd cov.vdb urgReport simv.* csrc
#-------------------------------------------------------------------------------------------------------
cov    :
	urg -full64 -dir cov.vdb -report urgReport
	@echo "Coverage report generated in urgReport directory"


