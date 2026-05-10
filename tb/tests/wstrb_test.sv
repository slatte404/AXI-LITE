`ifndef WSTRB_TEST_SV
`define WSTRB_TEST_SV

class wstrb_test extends axi_base_test;
  `uvm_component_utils(wstrb_test)

  function new(string name = "wstrb_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // 设置默认 sequence
    uvm_config_db#(uvm_object_wrapper)::set(this, // 发信人：当前的 Test
                                            "env.agent.sqr.run_phase", // 收信人地址：指明是这个 sequencer 的 run_phase 
                                            "default_sequence", // 便条内容标签：这就是那个“暗号”
                                            axi_wstrb_seq::type_id::get());// 便条具体内容：这是 axi_wstrb_seq 的“身份证/图纸”
  endfunction
endclass

`endif
