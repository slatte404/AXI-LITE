`include "uvm_macros.svh"
import uvm_pkg::*;

`ifndef AXI_RW_SEQ_SV
`define AXI_RW_SEQ_SV

class axi_rw_seq extends uvm_sequence #(axi_trans_base);
  `uvm_object_utils(axi_rw_seq)

  function new(string name = "axi_rw_seq");
    super.new(name);
  endfunction

  virtual task body();
    axi_write_trans w_trans;
    axi_read_trans  r_trans;
    int i;

    // ==== 5 次写操作 ====
    for (i = 0; i < 5; i++) begin
      w_trans = axi_write_trans::type_id::create($sformatf("w_trans_%0d", i));
      assert(w_trans.randomize() with { addr inside {[0:15]}; data inside {[0:255]}; });
      //`uvm_info(get_type_name(), $sformatf("Start WRITE transaction addr=0x%0h data=0x%0h", w_trans.addr, w_trans.data), UVM_MEDIUM)
      start_item(w_trans);
      `uvm_info(get_type_name(), $sformatf("Start WRITE transaction addr=0x%0h data=0x%0h", w_trans.addr, w_trans.data), UVM_MEDIUM)
      finish_item(w_trans);
      `uvm_info(get_type_name(), $sformatf("Finish WRITE transaction addr=0x%0h data=0x%0h", w_trans.addr, w_trans.data), UVM_MEDIUM)
    end

    // ==== 5 次读操作 ====
    for (i = 0; i < 5; i++) begin
      r_trans = axi_read_trans::type_id::create($sformatf("r_trans_%0d", i));
      assert(r_trans.randomize() with { addr inside {[0:15]}; });
      `uvm_info(get_type_name(), $sformatf("Start READ transaction addr=0x%0h", r_trans.addr), UVM_MEDIUM)
      start_item(r_trans);
      finish_item(r_trans);
      `uvm_info(get_type_name(), $sformatf("Finish READ transaction addr=0x%0h data=0x%0h", w_trans.addr, w_trans.data), UVM_MEDIUM)
    end
  endtask
endclass

`endif // AXI_RW_SEQ_SV



