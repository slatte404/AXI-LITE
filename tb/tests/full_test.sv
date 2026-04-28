`ifndef AXI_RW_TEST_SV
`define AXI_RW_TEST_SV

class axi_full_test extends axi_lite_test;
  `uvm_component_utils(axi_full_test)

  function new(string name="axi_full_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    // 用子类 sequence 替换父类 sequence
    axi_rw_seq::type_id::set_type_override(axi_full_rw_seq::get_type());
    super.build_phase(phase);
  endfunction
endclass

`endif