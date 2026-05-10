`ifndef ERROR_TEST_SV
`define ERROR_TEST_SV

class axi_error_test extends axi_base_test;
  `uvm_component_utils(axi_error_test)

  function new(string name = "axi_error_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    axi_error_seq err_seq;
    
    // 重点：不要调用 super.run_phase()，否则会跑基类的 Smoke Test
    
    phase.raise_objection(this);
    err_seq = axi_error_seq::type_id::create("err_seq");
    err_seq.start(env.agent.sequencer); // 手动启动当前特有的 Sequence
    phase.drop_objection(this);
  endtask
endclass

`endif
