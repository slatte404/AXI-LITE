module tb_top;
  `include "uvm_macros.svh"
  import uvm_pkg::*;
  
  // -------------------
  // Clock & reset
  // -------------------
  logic aclk;
  logic aresetn;

  initial aclk = 0;
  always #5 aclk = ~aclk;

  initial begin
    aresetn = 0;
    #10
    aresetn = 1;
    #10
    aresetn = 0;
    #30;
    aresetn = 1;
  end

  // -------------------
  // AXI-Lite interface
  // -------------------
  axi_lite_if #(6,64) vif(aclk, aresetn);

  // -------------------
  // DUT 实例化
  // -------------------
  axi_lite_slave dut(
    .aclk(aclk),
    .aresetn(aresetn),

    .s_axi_awaddr (vif.awaddr),
    .s_axi_awvalid(vif.awvalid),
    .s_axi_awready(vif.awready),

    .s_axi_wdata  (vif.wdata),
    .s_axi_wstrb  (vif.wstrb),
    .s_axi_wvalid (vif.wvalid),
    .s_axi_wready (vif.wready),

    .s_axi_bresp  (vif.bresp),
    .s_axi_bvalid (vif.bvalid),
    .s_axi_bready (vif.bready),

    .s_axi_araddr (vif.araddr),
    .s_axi_arvalid(vif.arvalid),
    .s_axi_arready(vif.arready),

    .s_axi_rdata  (vif.rdata),
    .s_axi_rresp  (vif.rresp),
    .s_axi_rvalid (vif.rvalid),
    .s_axi_rready (vif.rready),

    .regs_out()
  );
  
// assertion instantiate using virtual interface
axi_lite_slave_assertions #(
    .ADDR_WIDTH(6),
    .DATA_WIDTH(64),
    .REG_NUM(6)
) dut_assertions (
    .aclk(aclk),
    .aresetn(aresetn),

    // bind the signals directly from the virtual interface
    .s_axi_awaddr (vif.awaddr),
    .s_axi_awvalid(vif.awvalid),
    .s_axi_awready(vif.awready),

    .s_axi_wdata  (vif.wdata),
    .s_axi_wstrb  (vif.wstrb),
    .s_axi_wvalid (vif.wvalid),
    .s_axi_wready (vif.wready),

    .s_axi_bresp  (vif.bresp),
    .s_axi_bvalid (vif.bvalid),
    .s_axi_bready (vif.bready),

    .s_axi_araddr (vif.araddr),
    .s_axi_arvalid(vif.arvalid),
    .s_axi_arready(vif.arready),

    .s_axi_rdata  (vif.rdata),
    .s_axi_rresp  (vif.rresp),
    .s_axi_rvalid (vif.rvalid),
    .s_axi_rready (vif.rready)
);


  // -------------------
  // Run UVM test
  // -------------------
  initial begin
    // dump FSDB
    $fsdbDumpfile("tb.fsdb");
    $fsdbDumpvars(0, tb_top);  // 推荐 dump 整个 tb_top，这样不仅能看到 dut，还能看到接口信号

    // 配置 virtual interface
    uvm_config_db#(virtual axi_lite_if)::set(null, "uvm_test_top", "vif", vif);

    // 启动 test
    run_test();
  end

endmodule


