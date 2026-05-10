`ifndef _AXI_SEQ_PKG_
`define _AXI_SEQ_PKG_
package axi_seq_pkg;
  import uvm_pkg::*;
  import axi_env_pkg::*;
  `include "../tb/sequences/axi_lite_seq.sv"
  `include "../tb/sequences/axi_full_seq.sv"
  `include "../tb/sequences/axi_random_seq.sv"
  `include "../tb/sequences/axi_wr_addr_seq.sv"
  `include "../tb/sequences/axi_wstrb_seq.sv"
  `include "../tb/sequences/axi_error_seq.sv"
endpackage : axi_seq_pkg
`endif

