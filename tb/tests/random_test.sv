`ifndef AXI_RANDOM_TEST_SV
`define AXI_RANDOM_TEST_SV

class axi_random_test extends axi_lite_test;
  `uvm_component_utils(axi_random_test)

  function new(string name="axi_random_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    // 用子类 sequence 替换父类 sequence
    axi_rw_seq::type_id::set_type_override(axi_random_test_seq::get_type());
    super.build_phase(phase);
  endfunction
endclass

`endif