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
    
    // 选定 6 个 64-bit 对齐的物理地址 (也就是那 6 个寄存器的入口)
    int test_addrs[] = '{0, 8, 16, 24, 32, 40};
    
    // 给它们准备 6 个非常好认的“魔数”测试数据
    bit [63:0] test_data[] = '{
      64'h1111_1111_1111_1111, 
      64'h2222_2222_2222_2222, 
      64'h3333_3333_3333_3333, 
      64'h4444_4444_4444_4444, 
      64'h5555_5555_5555_5555, 
      64'h6666_6666_6666_6666
    };

    `uvm_info(get_type_name(), "==========================================", UVM_LOW)
    `uvm_info(get_type_name(), "===       STARTING SMOKE TEST          ===", UVM_LOW)
    `uvm_info(get_type_name(), "==========================================", UVM_LOW)

    // ==== 1. 顺序写操作 ====
    foreach (test_addrs[i]) begin
      w_trans = axi_write_trans::type_id::create($sformatf("w_trans_%0d", i));
      
      // 不使用完全随机，而是指定固定的地址、数据，并开启所有字节 (8'hFF)
      assert(w_trans.randomize() with {
        addr == test_addrs[i];
        data == test_data[i];
        strobe == 8'hFF;
      });
      
      start_item(w_trans);
      finish_item(w_trans);
      `uvm_info(get_type_name(), $sformatf("SMOKE WRITE: addr=0x%0h, data=0x%0h", w_trans.addr, w_trans.data), UVM_LOW)
    end

    // 给总线一点喘息的时间
    #50;

    // ==== 2. 顺序读操作 ====
    foreach (test_addrs[i]) begin
      r_trans = axi_read_trans::type_id::create($sformatf("r_trans_%0d", i));
      
      // 读取刚才写入的地址
      assert(r_trans.randomize() with {
        addr == test_addrs[i];
      });
      
      start_item(r_trans);
      finish_item(r_trans);
      `uvm_info(get_type_name(), $sformatf("SMOKE READ REQUEST: addr=0x%0h", r_trans.addr), UVM_LOW)
    end

    `uvm_info(get_type_name(), "==========================================", UVM_LOW)
    `uvm_info(get_type_name(), "===       SMOKE TEST FINISHED          ===", UVM_LOW)
    `uvm_info(get_type_name(), "==========================================", UVM_LOW)
  endtask
endclass

`endif // AXI_RW_SEQ_SV
