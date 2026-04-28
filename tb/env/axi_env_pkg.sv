`ifndef _AXI_ENV_PKG_
`define _AXI_ENV_PKG_
package axi_env_pkg;
  import uvm_pkg::*;
  `include "../tb/env/axi_lite_trans.sv"
  `include "../tb/env/axi_lite_sequencer.sv"
  `include "../tb/env/axi_lite_driver.sv"
  `include "../tb/env/axi_lite_monitor.sv"
  `include "../tb/env/axi_lite_scoreboard.sv"
  `include "../tb/env/axi_lite_coverage.sv"
  `include "../tb/env/axi_lite_agent.sv"
  `include "../tb/env/axi_lite_env.sv"
endpackage : axi_env_pkg
`endif
