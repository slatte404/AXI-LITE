class axi_lite_agent extends uvm_agent;
  `uvm_component_utils(axi_lite_agent)

  
  // 子组件
  axi_lite_driver   driver;
  axi_lite_monitor  monitor;
  axi_lite_sequencer sequencer; // 需要单独写一个 sequencer
  virtual axi_lite_if vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db#(virtual axi_lite_if)::get(this,"","vif",vif))
      `uvm_fatal("NO_VIF","Virtual interface not found")

    // 创建子组件
    monitor = axi_lite_monitor::type_id::create("monitor", this);

    if(get_is_active() == UVM_ACTIVE) begin
      driver    = axi_lite_driver::type_id::create("driver", this);
      sequencer = axi_lite_sequencer::type_id::create("sequencer", this);

      // 通过 config_db 传接口给 driver 和 monitor
      uvm_config_db#(virtual axi_lite_if)::set(this, "driver",  "vif", vif);
      uvm_config_db#(virtual axi_lite_if)::set(this, "monitor", "vif", vif);
    end
    else begin
      // passive agent 只有 monitor
      uvm_config_db#(virtual axi_lite_if)::set(this, "monitor", "vif", vif);
    end
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if(get_is_active() == UVM_ACTIVE) begin
      driver.seq_item_port.connect(sequencer.seq_item_export);
    end
  endfunction
endclass

