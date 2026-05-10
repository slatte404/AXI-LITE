`ifndef AXI_ERROR_SEQ_SV
`define AXI_ERROR_SEQ_SV

class axi_error_seq extends uvm_sequence #(axi_trans_base);
  `uvm_object_utils(axi_error_seq)

  function new(string name = "axi_error_seq");
    super.new(name);
  endfunction

  virtual task body();
    axi_write_trans w_tr;
    axi_read_trans  r_tr;

    `uvm_info(get_type_name(), "Starting Error (Out-of-Bounds) Test Sequence", UVM_LOW)

    // 1. 访问越界地址 (REG_NUM=6, 每个 8 字节, 所以有效范围 0-47)
    // 尝试访问地址 48, 56, 63 等
    repeat(5) begin
      int illegal_addr;
      void'(std::randomize(illegal_addr) with {illegal_addr >= 48; illegal_addr < 64;});
      
      `uvm_info(get_type_name(), $sformatf("Attempting Illegal Write to addr 0x%0h", illegal_addr), UVM_MEDIUM)
      `uvm_do_with(w_tr, {addr == illegal_addr;})
      
      `uvm_info(get_type_name(), $sformatf("Attempting Illegal Read from addr 0x%0h", illegal_addr), UVM_MEDIUM)
      `uvm_do_with(r_tr, {addr == illegal_addr;})
    end

    `uvm_info(get_type_name(), "Error Test Sequence Finished", UVM_LOW)
  endtask
endclass

`endif
