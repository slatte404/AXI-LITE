`ifndef AXI_LITE_AGENT_SV
`define AXI_LITE_AGENT_SV

class axi_lite_agent extends uvm_agent;
  `uvm_component_utils(axi_lite_agent)

  // ==== 子组件定义 ====
  axi_lite_driver   driver;
  axi_lite_monitor  monitor;
  axi_lite_sequencer sequencer;
  
  virtual axi_lite_if vif;

  // ==== 方法声明 (extern) ====
  extern function new(string name, uvm_component parent);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);

endclass

// =========================================================================
// 方法实现区 (外部实现)
// =========================================================================

function axi_lite_agent::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction

function void axi_lite_agent::build_phase(uvm_phase phase);
  super.build_phase(phase);

  if(!uvm_config_db#(virtual axi_lite_if)::get(this,"","vif",vif))
    `uvm_fatal("NO_VIF","Virtual interface not found in agent")

  monitor = axi_lite_monitor::type_id::create("monitor", this);

  if(get_is_active() == UVM_ACTIVE) begin
    driver    = axi_lite_driver::type_id::create("driver", this);
    sequencer = axi_lite_sequencer::type_id::create("sequencer", this);

    uvm_config_db#(virtual axi_lite_if)::set(this, "driver",  "vif", vif);
    uvm_config_db#(virtual axi_lite_if)::set(this, "monitor", "vif", vif);
  end
  else begin
    uvm_config_db#(virtual axi_lite_if)::set(this, "monitor", "vif", vif);
  end
endfunction

function void axi_lite_agent::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  if(get_is_active() == UVM_ACTIVE) begin
    driver.seq_item_port.connect(sequencer.seq_item_export);
  end
endfunction

`endif
