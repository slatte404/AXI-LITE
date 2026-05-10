`ifndef WSTRB_TEST_SV
`define WSTRB_TEST_SV

class axi_wstrb_test extends axi_base_test;
  `uvm_component_utils(axi_wstrb_test)

  function new(string name = "axi_wstrb_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    axi_wstrb_seq wstrb_seq;
    
    // 重点：不要调用 super.run_phase()，否则会跑基类的 Smoke Test
    
    phase.raise_objection(this);
    wstrb_seq = axi_wstrb_seq::type_id::create("wstrb_seq");
    wstrb_seq.start(env.agent.sequencer); // 手动启动当前特有的 Sequence
    phase.drop_objection(this);
  endtask
endclass

`endif
