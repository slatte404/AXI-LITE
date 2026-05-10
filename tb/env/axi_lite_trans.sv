`include "uvm_macros.svh"
import uvm_pkg::*;

`ifndef AXI_TRANS_SV
`define AXI_TRANS_SV

class axi_trans_base extends uvm_sequence_item;
  `uvm_object_utils(axi_trans_base)
  function new(string name="axi_trans_base"); super.new(name); endfunction
endclass

class axi_write_trans extends axi_trans_base;
  rand bit [31:0] addr;
  rand bit [63:0] data;
  rand bit [7:0] strobe;

  // 新增：通道延迟控制参数
  rand int aw_delay;
  rand int w_delay;

  // 约束：延迟在合理范围内，避免仿真等待过久
  constraint delay_c {
    aw_delay >= 0; aw_delay <= 10;
    w_delay  >= 0; w_delay  <= 10;
  }

  `uvm_object_utils_begin(axi_write_trans)
    `uvm_field_int(addr, UVM_ALL_ON)
    `uvm_field_int(data, UVM_ALL_ON)
    `uvm_field_int(strobe, UVM_ALL_ON)
    `uvm_field_int(aw_delay, UVM_ALL_ON)
    `uvm_field_int(w_delay, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name="axi_write_trans");
    super.new(name);
  endfunction
endclass

class axi_read_trans extends axi_trans_base;
  rand bit [31:0] addr;
  rand bit [63:0] data;
  `uvm_object_utils_begin(axi_read_trans)
    `uvm_field_int(addr, UVM_ALL_ON)
    `uvm_field_int(data, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name="axi_read_trans");
    super.new(name);
  endfunction
endclass

`endif 

