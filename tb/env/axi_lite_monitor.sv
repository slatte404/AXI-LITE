class axi_lite_monitor extends uvm_component;
  `uvm_component_utils(axi_lite_monitor)

  virtual axi_lite_if vif;
  uvm_analysis_port #(axi_trans_base) ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // 获取 vif
    if (!uvm_config_db#(virtual axi_lite_if)::get(this, "", "vif", vif))
      `uvm_fatal(get_type_name(), "No virtual interface specified for axi_lite_monitor")

    // 同时把 vif 传给 scoreboard
    uvm_config_db#(virtual axi_lite_if)::set(this, "*scoreboard*", "vif", vif);
  endfunction

  virtual task run_phase(uvm_phase phase);
    axi_write_trans w_tr;
    axi_read_trans  r_tr;

    // 等待 reset 释放
    @(posedge vif.aresetn);

    forever begin
      @(posedge vif.aclk);

      if (!vif.aresetn) begin
        continue;
      end

      // ==== 写通道监控 ====
      if (vif.awvalid && vif.awready) begin
        w_tr = axi_write_trans::type_id::create("w_tr");
        w_tr.addr   = vif.awaddr;
        w_tr.data   = vif.wdata;
        w_tr.strobe = vif.wstrb;
        ap.write(w_tr);

        `uvm_info(get_type_name(),
          $sformatf("Monitor captured WRITE addr=0x%0h data=0x%0h strobe=0x%0h",
                     w_tr.addr, w_tr.data, w_tr.strobe),
          UVM_LOW)
      end

      // ==== 读通道监控 ====
      if (vif.arvalid && vif.arready) begin
        r_tr = axi_read_trans::type_id::create("r_tr");
        r_tr.addr = vif.araddr;

        // 等待 R 通道数据返回，同时处理 reset
        wait ((vif.rvalid && vif.rready) || (!vif.aresetn));
        if (!vif.aresetn) begin
          continue;
        end

        r_tr.data = vif.rdata;
        ap.write(r_tr);

        `uvm_info(get_type_name(),
          $sformatf("Monitor captured READ addr=0x%0h data=0x%0h",
                     r_tr.addr, r_tr.data),
          UVM_LOW)
      end
    end
  endtask
endclass



