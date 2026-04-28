`include "uvm_macros.svh"
import uvm_pkg::*;

`ifndef AXI_DRIVER_SV
`define AXI_DRIVER_SV

localparam ADDR_WIDTH = 32;
localparam DATA_WIDTH = 64;

class axi_lite_driver extends uvm_driver #(axi_trans_base);
  `uvm_component_utils(axi_lite_driver)

  // transaction 对象
  axi_trans_base tr;
  axi_write_trans w_tr;
  axi_read_trans  r_tr;

  virtual axi_lite_if vif; // interface
  bit in_reset; // reset 状态标志

  function new(string name, uvm_component parent);
    super.new(name, parent);
    in_reset = 0;
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual axi_lite_if)::get(this, "", "vif", vif))
      `uvm_fatal(get_type_name(), "No virtual interface specified for axi_lite_driver")
  endfunction

  // ----------------------------------------
  // run_phase: fork 两个任务
  // ----------------------------------------
  virtual task run_phase(uvm_phase phase);
    fork
      monitor_reset();         // 监控复位
      process_transactions();  // 处理事务
    join
  endtask

  // ----------------------------------------
  // 监控 reset
  // ----------------------------------------
  virtual task monitor_reset();
    forever begin
      @(posedge vif.aclk); // 每个时钟周期检查
      in_reset = !vif.aresetn;
      if (in_reset) begin
        clean_up_signals();
        clean_up_read_signals();
      end
    end
  endtask

  // ----------------------------------------
  // 处理事务
  // ----------------------------------------
  virtual task process_transactions();
    forever begin
      // 等待 reset 解除
      wait_until_reset_deasserted();

      // 获取 transaction
      seq_item_port.get_next_item(tr);
      `uvm_info(get_type_name(), $sformatf("GET transaction type = %s",tr.get_type_name()), UVM_MEDIUM)

      // 根据 transaction 类型执行
      if ($cast(w_tr, tr)) begin
        write_with_reset(w_tr.addr, w_tr.data, w_tr.strobe);
        `uvm_info(get_type_name(), $sformatf("WRITE addr=0x%0h data=0x%0h", w_tr.addr, w_tr.data), UVM_MEDIUM)
      end
      else if ($cast(r_tr, tr)) begin
        read_with_reset(r_tr.addr, r_tr.data);
        `uvm_info(get_type_name(), $sformatf("READ addr=0x%0h data=0x%0h", r_tr.addr, r_tr.data), UVM_MEDIUM)
      end

      seq_item_port.item_done();
    end
  endtask

  // ----------------------------------------
  // 等待 reset 解除
  // ----------------------------------------
  virtual task wait_until_reset_deasserted();
    while (in_reset) @(posedge vif.aclk);
    @(posedge vif.aclk); // 保证稳定
  endtask

  // ----------------------------------------
  // Write transaction
  // ----------------------------------------
  task write_with_reset(input [ADDR_WIDTH-1:0] addr, input [DATA_WIDTH-1:0] data, input [DATA_WIDTH/8-1:0] strobe);
    // reset 有效时直接不做操作
    if (in_reset) disable write_with_reset;

    vif.awaddr  <= addr;
    vif.awvalid <= 1;
    vif.wdata   <= data;
    vif.wstrb   <= strobe;
    vif.wvalid  <= 1;
    vif.bready  <= 1;

    wait_with_reset(vif.awready);
    if (in_reset) clean_up_signals();

    wait_with_reset(vif.wready);
    if (in_reset) clean_up_signals();

    @(posedge vif.aclk);
    vif.awvalid <= 0;
    vif.wvalid <= 0;

    wait_with_reset(vif.bvalid);
    if (in_reset) clean_up_signals();

    @(posedge vif.aclk);
    clean_up_signals();
  endtask

  // ----------------------------------------
  // Read transaction
  // ----------------------------------------
  task read_with_reset(input [ADDR_WIDTH-1:0] addr, output [DATA_WIDTH-1:0] data);
    if (in_reset) begin
      data = '0;
      disable read_with_reset;
    end

    vif.araddr  <= addr;
    vif.arvalid <= 1;
    vif.rready  <= 1;

    wait_with_reset(vif.arready);
    if (in_reset) clean_up_read_signals();

    @(posedge vif.aclk);
    vif.arvalid <= 0;

    wait_with_reset(vif.rvalid);
    if (in_reset) clean_up_read_signals();

    data = vif.rdata;

    @(posedge vif.aclk);
    clean_up_read_signals();
  endtask

  // ----------------------------------------
  // 可中断等待任务
  // ----------------------------------------
  task wait_with_reset(ref logic signal);
    while (!signal && !in_reset) @(posedge vif.aclk);
    // 结束时 signal=1 或 reset=1，返回
  endtask

  // ----------------------------------------
  // 清理写信号
  // ----------------------------------------
  task clean_up_signals();
    vif.awaddr  <= '0;
    vif.awvalid <= 0;
    vif.wdata   <= '0;
    vif.wstrb   <= '0;
    vif.wvalid  <= 0;
    vif.bready  <= 0;
  endtask

  // ----------------------------------------
  // 清理读信号
  // ----------------------------------------
  task clean_up_read_signals();
    vif.araddr  <= '0;
    vif.arvalid <= 0;
    vif.rready  <= 0;
  endtask

endclass

`endif


