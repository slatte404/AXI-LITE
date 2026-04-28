`timescale 1ns/1ps

module tb_axi_lite_slave;

  // 参数
  localparam ADDR_WIDTH = 6;
  localparam DATA_WIDTH = 64;
  localparam REG_NUM    = 6;

  // 信号
  logic aclk;
  logic aresetn;

  // AXI 信号
  logic [ADDR_WIDTH-1:0]   s_axi_awaddr;
  logic                    s_axi_awvalid;
  logic                    s_axi_awready;

  logic [DATA_WIDTH-1:0]   s_axi_wdata;
  logic [DATA_WIDTH/8-1:0] s_axi_wstrb;
  logic                    s_axi_wvalid;
  logic                    s_axi_wready;

  logic [1:0]              s_axi_bresp;
  logic                    s_axi_bvalid;
  logic                    s_axi_bready;

  logic [ADDR_WIDTH-1:0]   s_axi_araddr;
  logic                    s_axi_arvalid;
  logic                    s_axi_arready;

  logic [DATA_WIDTH-1:0]   s_axi_rdata;
  logic [1:0]              s_axi_rresp;
  logic                    s_axi_rvalid;
  logic                    s_axi_rready;

  logic [DATA_WIDTH-1:0]   regs_out [REG_NUM];

  // 时钟
  initial aclk = 0;
  always #5 aclk = ~aclk; // 100MHz 时钟

  // DUT 实例化
  axi_lite_slave #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .REG_NUM(REG_NUM)
  ) dut (
    .aclk(aclk),
    .aresetn(aresetn),
    .s_axi_awaddr(s_axi_awaddr),
    .s_axi_awvalid(s_axi_awvalid),
    .s_axi_awready(s_axi_awready),
    .s_axi_wdata(s_axi_wdata),
    .s_axi_wstrb(s_axi_wstrb),
    .s_axi_wvalid(s_axi_wvalid),
    .s_axi_wready(s_axi_wready),
    .s_axi_bresp(s_axi_bresp),
    .s_axi_bvalid(s_axi_bvalid),
    .s_axi_bready(s_axi_bready),
    .s_axi_araddr(s_axi_araddr),
    .s_axi_arvalid(s_axi_arvalid),
    .s_axi_arready(s_axi_arready),
    .s_axi_rdata(s_axi_rdata),
    .s_axi_rresp(s_axi_rresp),
    .s_axi_rvalid(s_axi_rvalid),
    .s_axi_rready(s_axi_rready),
    .regs_out(regs_out)
  );

  // 复位
  initial begin
    aresetn = 0;
    #50;
    aresetn = 1;
  end

  // 写任务
  task axi_write(input [ADDR_WIDTH-1:0] addr, input [DATA_WIDTH-1:0] data);
    begin
      @(posedge aclk);
      s_axi_awaddr  <= addr;
      s_axi_awvalid <= 1;
      s_axi_wdata   <= data;
      s_axi_wstrb   <= {DATA_WIDTH/8{1'b1}};
      s_axi_wvalid  <= 1;
      s_axi_bready  <= 1;

      // 等待 ready
      wait (s_axi_awready && s_axi_wready);
      @(posedge aclk);
      s_axi_awvalid <= 0;
      s_axi_wvalid  <= 0;

      // 等待 bvalid
      wait (s_axi_bvalid);
      @(posedge aclk);
      s_axi_bready  <= 0;
    end
  endtask

  // 读任务
  task axi_read(input [ADDR_WIDTH-1:0] addr, output [DATA_WIDTH-1:0] data);
    begin
      @(posedge aclk);
      s_axi_araddr  <= addr;
      s_axi_arvalid <= 1;
      s_axi_rready  <= 1;

      // 等待 ready
      wait (s_axi_arready);
      @(posedge aclk);
      s_axi_arvalid <= 0;

      // 等待 rvalid
      wait (s_axi_rvalid);
      data = s_axi_rdata;
      @(posedge aclk);
      s_axi_rready <= 0;
    end
  endtask

    // FSDB waveform
    initial begin
        $fsdbDumpfile("tb.fsdb");
        $fsdbDumpvars(0, tb_axi_lite_slave);
        //$fsdbDumpMDA();
        //$display("FSDB waveform generation started...");
    end
    
  logic [DATA_WIDTH-1:0] rdata;
  // 测试流程
  initial begin
    // 初始化信号
    s_axi_awaddr  = 0;
    s_axi_awvalid = 0;
    s_axi_wdata   = 0;
    s_axi_wstrb   = 0;
    s_axi_wvalid  = 0;
    s_axi_bready  = 0;
    s_axi_araddr  = 0;
    s_axi_arvalid = 0;
    s_axi_rready  = 0;

    wait(aresetn == 1);

    $display("\n=== Test: Simple Write and Read ===");

    // 写寄存器 0
    axi_write(6'h00, 64'hDEADBEEFCAFEBABE);

    // 读寄存器 0
    axi_read(6'h00, rdata);

    $display("Read data = 0x%h", rdata);

    if (rdata == 64'hDEADBEEFCAFEBABE)
      $display("TEST PASS ✅");
    else
      $display("TEST FAIL ❌");

    #50;
    $finish;
  end

endmodule
