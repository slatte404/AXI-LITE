`include "uvm_macros.svh"
import uvm_pkg::*;

`ifndef AXI_RANDOM_TEST_SEQ_SV
`define AXI_RANDOM_TEST_SEQ_SV

class axi_random_test_seq extends axi_rw_seq;
  `uvm_object_utils(axi_random_test_seq)

  function new(string name = "axi_random_test_seq");
    super.new(name);
  endfunction

  virtual task body();
    axi_write_trans w_trans;
    axi_read_trans  r_trans;
    int i;

for (i = 0; i < 100 ; i++) begin
      if (!$urandom_range(0,1)) begin
        w_trans = axi_write_trans::type_id::create($sformatf("w_trans_%0d", i));
        if (!w_trans.randomize() with { 
          strobe != 0; 
          addr >= 32'h8;
          addr <= 32'h30;
          addr[2:0] == 3'b000; // 8字节对齐,
          data dist {
              32'h0000_0000, 32'h1111_1111, 32'h2222_2222, 32'h3333_3333,
              32'h4444_4444, 32'h5555_5555, 32'h6666_6666, 32'h7777_7777,
              32'h8888_8888, 32'h9999_9999, 32'hAAAA_AAAA, 32'hBBBB_BBBB,
              32'hCCCC_CCCC, 32'hDDDD_DDDD, 32'hEEEE_EEEE, 32'hFFFF_FFFF
          };
        }) begin
          `uvm_error(get_type_name(), "Randomization failed!")
        end
        start_item(w_trans);
        `uvm_info(get_type_name(), $sformatf("WRITE addr=0x%0h data=0x%0h", w_trans.addr, w_trans.data), UVM_MEDIUM)
        finish_item(w_trans);
        `uvm_info(get_type_name(), $sformatf("WRITE completed addr=0x%0h data=0x%0h", w_trans.addr, w_trans.data), UVM_MEDIUM)
      end else begin
        // 读事务
        r_trans = axi_read_trans::type_id::create($sformatf("r_trans_%0d", i));
        if (!r_trans.randomize() with { 
          addr >= 32'h8;
          addr <= 32'h30;
          addr[2:0] == 3'b000; // 8字节对齐,
        }) begin
          `uvm_error(get_type_name(), "Randomization failed!")
        end
        start_item(r_trans);
        finish_item(r_trans);
        `uvm_info(get_type_name(), $sformatf("READ addr=0x%0h data=0x%0h", r_trans.addr, r_trans.data), UVM_MEDIUM)
      end
    end
  endtask
endclass

`endif // AXI_FULL_RW_SEQ_S
