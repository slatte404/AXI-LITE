`include "uvm_macros.svh"
import uvm_pkg::*;

`ifndef AXI_WR_ADDR_SEQ_SV
`define AXI_WR_ADDR_SEQ_SV

class axi_wr_addr_seq extends axi_rw_seq;
  `uvm_object_utils(axi_wr_addr_seq)

  function new(string name = "axi_wr_addr_seq");
    super.new(name);
  endfunction

  virtual task body();
    axi_write_trans w_trans;
    axi_read_trans  r_trans;
    int i;

    // 一次读写
    for (i = 0; i < 100 ; i++) begin
      w_trans = axi_write_trans::type_id::create($sformatf("w_trans_%0d", i));
      if (!w_trans.randomize() with { 
        strobe != 0; 
        addr dist{
            [32'h0000_0000 : 32'h0000_002F] :/ 5,
            [32'h0000_0030 : 32'h0000_0060] :/5
        };
        }) begin
        `uvm_error(get_type_name(), "Randomization failed!")
      end
      start_item(w_trans);
      `uvm_info(get_type_name(), $sformatf("WRITE addr=0x%0h data=0x%0h", w_trans.addr, w_trans.data), UVM_MEDIUM)
      finish_item(w_trans);
      `uvm_info(get_type_name(), $sformatf("WRITE completed addr=0x%0h data=0x%0h", w_trans.addr, w_trans.data), UVM_MEDIUM)

      r_trans = axi_read_trans::type_id::create($sformatf("r_trans_%0d", i));
 	  r_trans.addr = w_trans.addr;
      start_item(r_trans);
      finish_item(r_trans);
      `uvm_info(get_type_name(), $sformatf("READ addr=0x%0h data=0x%0h", r_trans.addr, r_trans.data), UVM_MEDIUM)
    end
  endtask
endclass

`endif
