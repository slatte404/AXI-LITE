`ifndef AXI_BASE_TEST_SV
`define AXI_BASE_TEST_SV

class axi_base_test extends uvm_test;
  `uvm_component_utils(axi_base_test)

  // virtual interface
  virtual axi_lite_if vif;

  // environment
  axi_lite_env env;

  // sequence 基类泛型
  axi_rw_seq m_seq;

  function new(string name="axi_base_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  // build_phase 创建环境和 sequence
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // 创建 environment
    env = axi_lite_env::type_id::create("env", this);

    // 获取 virtual interface
    if (!uvm_config_db#(virtual axi_lite_if)::get(null, "uvm_test_top", "vif", vif))
      `uvm_fatal("NO_VIF", "No virtual interface found in config DB");

    // 将 vif 传给 agent
    uvm_config_db#(virtual axi_lite_if)::set(this, "env.agent", "vif", vif);

    // 设置 agent active 模式
    uvm_config_db#(uvm_active_passive_enum)::set(this, "env.agent", "is_active", UVM_ACTIVE);

    // 创建 sequence（子类 sequence）
    m_seq = axi_rw_seq::type_id::create("m_seq");
  endfunction

  // run_phase 启动 sequence
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);

    // 启动 sequence 发送 transaction
    m_seq.start(env.agent.sequencer);

    phase.drop_objection(this);
  endtask
endclass

`endif
