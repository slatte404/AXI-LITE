`ifndef AXI_LITE_ENV_SV
`define AXI_LITE_ENV_SV

class axi_lite_env extends uvm_env;
  `uvm_component_utils(axi_lite_env)

  // ==== 子组件定义 ====
  axi_lite_agent     agent;
  axi_lite_scoreboard sb;
  axi_lite_cov       cov;

  // ==== 方法声明 (extern) ====
  extern function new(string name, uvm_component parent);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);

endclass

// =========================================================================
// 方法实现区 (外部实现)
// =========================================================================

function axi_lite_env::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction

function void axi_lite_env::build_phase(uvm_phase phase);
  super.build_phase(phase);
  
  // 实例化三个核心组件：Agent, Scoreboard, Coverage
  agent = axi_lite_agent::type_id::create("agent", this);
  sb    = axi_lite_scoreboard::type_id::create("sb", this);
  cov   = axi_lite_cov::type_id::create("cov", this);
endfunction

function void axi_lite_env::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  
  // 将 Monitor 的 Analysis Port (ap) 广播通道连接到计分板和覆盖率组件
  agent.monitor.ap.connect(sb.item_collected_export);
  agent.monitor.ap.connect(cov.analysis_export);
endfunction

`endif
