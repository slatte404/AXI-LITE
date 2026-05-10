`ifndef AXI_WSTRB_SEQ_SV
`define AXI_WSTRB_SEQ_SV

class axi_wstrb_seq extends uvm_sequence #(axi_trans_base);
  `uvm_object_utils(axi_wstrb_seq)

  function new(string name = "axi_wstrb_seq");
    super.new(name);
  endfunction

  virtual task body();
    axi_write_trans w_tr;
    axi_read_trans  r_tr;
    logic [63:0] ref_data;
    int addr;

    `uvm_info(get_type_name(), "Starting Strobe (WSTRB) Test Sequence", UVM_LOW)

    // 对每一个寄存器进行各种 strobe 测试
    for (int i = 0; i < 6; i++) begin
      addr = i * 8;
      
      // 1. 先写满全 F，作为背景
      `uvm_do_with(w_tr, {addr == local::addr; data == 64'hFFFF_FFFF_FFFF_FFFF; strobe == 8'hFF;})
      
      // 2. 测试单字节写入 (Byte 0)
      `uvm_do_with(w_tr, {addr == local::addr; data == 64'hAA; strobe == 8'h01;})
      `uvm_do_with(r_tr, {addr == local::addr;})
      // 预期: FFFF_FFFF_FFFF_FFAA (假设 Slave 正确处理)

      // 3. 测试半字写入 (Bytes 2-3)
      `uvm_do_with(w_tr, {addr == local::addr; data == 64'hBBBB_0000; strobe == 8'h0C;})
      `uvm_do_with(r_tr, {addr == local::addr;})
      
      // 4. 随机 Strobe 测试
      repeat(3) begin
        `uvm_do_with(w_tr, {addr == local::addr;})
        `uvm_do_with(r_tr, {addr == local::addr;})
      end
    end

    `uvm_info(get_type_name(), "Strobe Test Sequence Finished", UVM_LOW)
  endtask
endclass

`endif
