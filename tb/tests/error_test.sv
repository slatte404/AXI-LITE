`ifndef ERROR_TEST_SV
`define ERROR_TEST_SV

class error_test extends axi_base_test;
  `uvm_component_utils(error_test)

  function new(string name = "error_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // 设置默认 sequence
    uvm_config_db#(uvm_object_wrapper)::set(this, 
                                            "env.agent.sqr.run_phase", 
                                            "default_sequence", 
                                            axi_error_seq::type_id::get());
  endfunction
endclass

`endif
