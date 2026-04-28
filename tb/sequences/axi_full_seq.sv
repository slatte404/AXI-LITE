`include "uvm_macros.svh"
import uvm_pkg::*;

`ifndef AXI_FULL_RW_SEQ_SV
`define AXI_FULL_RW_SEQ_SV

class axi_full_rw_seq extends axi_rw_seq;
  `uvm_object_utils(axi_full_rw_seq)

  function new(string name = "axi_full_rw_seq");
    super.new(name);
  endfunction

  virtual task body();
    axi_write_trans w_trans;
    axi_read_trans  r_trans;
    int i;

    // ==== 写满 6 个寄存器 ====
    for (i = 0; i < 6; i++) begin
      w_trans = axi_write_trans::type_id::create($sformatf("w_trans_%0d", i));
      // 可以自定义写入数据，这里写 i*10 作为例子
      //w_trans.addr = i + i*8;
      //w_trans.data = i * 10;
      if (!w_trans.randomize() with { strobe != 0; }) begin
        `uvm_error(get_type_name(), "Randomization failed!")
      end
      w_trans.addr = i + i*8;
      start_item(w_trans);
      `uvm_info(get_type_name(), $sformatf("WRITE addr=0x%0h data=0x%0h", w_trans.addr, w_trans.data), UVM_MEDIUM)
      finish_item(w_trans);
      `uvm_info(get_type_name(), $sformatf("WRITE completed addr=0x%0h data=0x%0h", w_trans.addr, w_trans.data), UVM_MEDIUM)
    end

    // ==== 读取 6 个寄存器 ====
    for (i = 0; i < 6; i++) begin
      r_trans = axi_read_trans::type_id::create($sformatf("r_trans_%0d", i));
      r_trans.addr = i + i*8;

      start_item(r_trans);
      finish_item(r_trans);
      `uvm_info(get_type_name(), $sformatf("READ addr=0x%0h data=0x%0h", r_trans.addr, r_trans.data), UVM_MEDIUM)
    end
  endtask
endclass

`endif // AXI_FULL_RW_SEQ_SV
