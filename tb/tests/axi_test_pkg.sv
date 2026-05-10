
`ifndef _AXI_TEST_PKG_
`define _AXI_TEST_PKG_
package axi_test_pkg;
  import uvm_pkg::*;
  import axi_env_pkg::*;
  import axi_seq_pkg::*;
  `include "../tb/tests/axi_base_test.sv"
  `include "../tb/tests/full_test.sv"
  `include "../tb/tests/random_test.sv"
  `include "../tb/tests/wraddr_test.sv"
  `include "../tb/tests/wstrb_test.sv"
  `include "../tb/tests/error_test.sv"
endpackage : axi_test_pkg
`endif

