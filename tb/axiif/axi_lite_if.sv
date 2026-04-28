interface axi_lite_if #(parameter ADDR_WIDTH=6, DATA_WIDTH=64) (input logic aclk, input logic aresetn);

  // AXI-Lite signals
  logic [ADDR_WIDTH-1:0]   awaddr;
  logic                    awvalid;
  logic                    awready;

  logic [DATA_WIDTH-1:0]   wdata;
  logic [DATA_WIDTH/8-1:0] wstrb;
  logic                    wvalid;
  logic                    wready;

  logic [1:0]              bresp;
  logic                    bvalid;
  logic                    bready;

  logic [ADDR_WIDTH-1:0]   araddr;
  logic                    arvalid;
  logic                    arready;
  
  logic [DATA_WIDTH-1:0]   rdata;
  logic [1:0]              rresp;
  logic                    rvalid;
  logic                    rready;

endinterface
