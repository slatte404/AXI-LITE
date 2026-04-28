# AXI-Lite Slave 项目全局索引

> **最后更新**: 2026-04-28
> **项目路径**: `d:\dv\axi_lite`
> **协议**: AMBA AXI4-Lite (Slave 端)
> **语言**: SystemVerilog / UVM / Python

---

## 一、项目概述

本项目是一个 **AXI4-Lite Slave** 的完整 RTL 设计与 UVM 验证环境。

- **DUT**: 一个可配置的 AXI-Lite 从端设备，内含 6 个 64-bit 寄存器，支持读/写/字节掩码(strobe)操作
- **验证**: 完整的 UVM 验证平台 + SVA 断言 + 形式验证属性 + 覆盖率收集 + 回归脚本
- **默认参数**: `ADDR_WIDTH=6, DATA_WIDTH=64, REG_NUM=6`

---

## 二、目录结构

```
axi_lite/
├── src/                        # RTL 设计源文件
│   ├── axi_top.sv              # 顶层模块 (axi_lite_slave) — 例化所有子模块
│   ├── decoder.sv              # 地址解码器 (address_decoder) — 纯组合逻辑
│   ├── write_channel.sv        # 写通道状态机 (IDLE→WRITE_DATA→SEND_RESPONSE)
│   ├── read_channel.sv         # 读通道状态机 (IDLE→READ_DATA→SEND_DATA)
│   └── register_file.sv        # 寄存器文件 — 支持 strobe 按字节写入
│
├── tb/                         # UVM 验证环境
│   ├── axiif/
│   │   └── axi_lite_if.sv      # AXI-Lite interface 定义 (参数化)
│   ├── assertion/
│   │   └── axi_lite_assertions.sv  # SVA 断言模块 (写通道 + 读通道协议检查 + cover)
│   ├── env/                    # UVM 组件
│   │   ├── axi_lite_trans.sv       # Transaction 类 (基类 + write_trans + read_trans)
│   │   ├── axi_lite_sequencer.sv   # Sequencer (简单参数化)
│   │   ├── axi_lite_driver.sv      # Driver — 支持 reset 中断/恢复
│   │   ├── axi_lite_monitor.sv     # Monitor — 监控 AW/W/AR/R 通道
│   │   ├── axi_lite_scoreboard.sv  # Scoreboard — 参考模型 + 读比较
│   │   ├── axi_lite_coverage.sv    # Coverage — 寄存器/strobe/数据覆盖组
│   │   ├── axi_lite_agent.sv       # Agent — 集成 driver/monitor/sequencer
│   │   ├── axi_lite_env.sv         # Environment — agent + scoreboard + coverage
│   │   └── axi_env_pkg.sv         # 环境包 (include 顺序)
│   ├── sequences/              # 测试序列
│   │   ├── axi_lite_seq.sv         # 基础序列: 5写+5读 (小范围随机)
│   │   ├── axi_full_seq.sv         # 满寄存器序列: 写满6个+读回6个
│   │   ├── axi_random_seq.sv       # 随机混合序列: 100次随机读写 (含地址对齐约束)
│   │   ├── axi_wr_addr_seq.sv      # 写地址测试序列: 100次写后立即读回验证
│   │   └── axi_seq_pkg.sv         # 序列包
│   ├── tests/                  # UVM Test 类
│   │   ├── axi_lite_test.sv        # Base test — 创建 env、配置 vif
│   │   ├── full_test.sv            # 满测试 — override为 axi_full_rw_seq
│   │   ├── random_test.sv          # 随机测试 — override为 axi_random_test_seq
│   │   ├── wraddr_test.sv          # 写地址测试 — override为 axi_wr_addr_seq
│   │   └── axi_test_pkg.sv        # 测试包
│   └── top/
│       └── tb_top.sv               # UVM 顶层 — 时钟/复位/DUT/断言例化
│
├── fv/                         # 形式验证
│   └── read_fv.sv              # 读通道形式验证属性 (5个 property)
│
├── sim/                        # 仿真运行
│   ├── Makefile                # VCS 编译+仿真+覆盖率 Makefile
│   ├── filelist.f              # 文件列表
│   ├── regression.py           # 回归测试脚本 (4个测试用例)
│   ├── pass_rate.py            # 通过率统计脚本 (解析 scoreboard 日志)
│   └── results/                # 回归结果输出目录
│
├── tb_module_check/            # 独立模块级别测试 (非UVM，直接激励)
│   ├── tb_decoder.sv           # 地址解码器独立测试
│   ├── tb_read.sv              # 读通道独立测试
│   ├── tb_write.sv             # 写通道独立测试
│   └── tb_top.sv               # 顶层集成独立测试 (写DEADBEEF+读回)
│
└── .ai_context/                # AI 上下文 (本目录)
    ├── project_index.md        # 本文件 — 项目全局索引
    └── changelogs/             # 每日修改记录
        └── 2026-04-28.md
```

---

## 三、RTL 设计详解

### 3.1 顶层模块 `axi_lite_slave` (axi_top.sv)

- **功能**: 例化 4 个子模块，连接内部信号
- **参数**: `ADDR_WIDTH=6, DATA_WIDTH=64, REG_NUM=6`
- **端口**: 完整 AXI-Lite 5 通道接口 + `regs_out` 寄存器输出
- **子模块**:
  - `address_decoder` → 地址解码 → wr_index / rd_index
  - `write_channel` → 写状态机 → write_enable, write_data, write_strb
  - `read_channel` → 读状态机 → rdata, rresp
  - `register_file` → 寄存器存储 → reg_file, regs_out

### 3.2 地址解码器 `address_decoder` (decoder.sv)

- **纯组合逻辑**, 无时钟
- 地址到寄存器索引转换: `index = addr[ADDR_WIDTH-1 : $clog2(DATA_WIDTH/8)]`
  - 64-bit 数据宽度下: 低3位忽略 (8字节对齐)
- 输出 `wr/rd_index_valid = (index < REG_NUM)`，用于越界检测

### 3.3 写通道 `write_channel` (write_channel.sv)

- **3 状态 FSM**: `IDLE → WRITE_DATA → SEND_RESPONSE`
- IDLE: 等待 awvalid 和 wvalid，均到达后进入 WRITE_DATA
- WRITE_DATA: 拉高 write_enable，锁存 wdata 和 wstrb
- SEND_RESPONSE: 拉高 bvalid，根据 wr_index_valid 给出 bresp (OKAY=00 / SLVERR=10)
- 握手完成后返回 IDLE

### 3.4 读通道 `read_channel` (read_channel.sv)

- **3 状态 FSM**: `IDLE → READ_DATA → SEND_DATA`
- IDLE: 等待 arvalid，握手后进入 READ_DATA
- READ_DATA: 根据 rd_index_valid 从 reg_file 取数据或返回 0，设置 rresp
- SEND_DATA: 拉高 rvalid，等待 rready 握手完成后回到 IDLE

### 3.5 寄存器文件 `register_file` (register_file.sv)

- 同步写入，支持 **按字节 strobe** 掩码写入
- 复位时所有寄存器清零
- `regs_out` 是 `reg_file` 的组合逻辑镜像输出

---

## 四、UVM 验证环境详解

### 4.1 架构

```
uvm_test_top (axi_lite_test / full_test / random_test / wraddr_test)
  └── env (axi_lite_env)
        ├── agent (axi_lite_agent, UVM_ACTIVE)
        │     ├── sequencer (axi_lite_sequencer)
        │     ├── driver (axi_lite_driver)
        │     └── monitor (axi_lite_monitor)
        ├── sb (axi_lite_scoreboard)
        └── cov (axi_lite_cov)
```

### 4.2 关键组件

| 组件 | 文件 | 说明 |
|------|------|------|
| Transaction | `axi_lite_trans.sv` | 基类 `axi_trans_base` + `axi_write_trans` (addr/data/strobe) + `axi_read_trans` (addr/data) |
| Driver | `axi_lite_driver.sv` | fork 两路: monitor_reset() + process_transactions()；支持 reset 中断恢复 |
| Monitor | `axi_lite_monitor.sv` | 监控 AW+W 通道(写), AR+R 通道(读)，通过 analysis_port 发送 |
| Scoreboard | `axi_lite_scoreboard.sv` | 维护 6-entry 参考模型 ref_mem[]，支持 strobe mask 比较 |
| Coverage | `axi_lite_coverage.sv` | 3 个 covergroup: reg_cover (寄存器索引), strobe_cover (strobe模式), data_cover (边界值) |
| Agent | `axi_lite_agent.sv` | 支持 ACTIVE/PASSIVE 模式 |
| Env | `axi_lite_env.sv` | 连接 monitor.ap → scoreboard + coverage |

### 4.3 测试用例

| Test | Sequence | 描述 |
|------|----------|------|
| `axi_lite_test` | `axi_rw_seq` | 基础: 5次随机写 + 5次随机读 |
| `axi_full_test` | `axi_full_rw_seq` | 写满6个寄存器 + 读回验证 |
| `axi_random_test` | `axi_random_test_seq` | 100次随机读写混合 (8字节对齐约束) |
| `axi_wraddr_test` | `axi_wr_addr_seq` | 100次写后立即读回 (含越界地址分布) |

### 4.4 断言 (SVA)

`axi_lite_assertions.sv` 中包含:
- **写通道**: AWREADY/WREADY 仅在 VALID 时拉高、握手后拉低、BVALID 持续到 BREADY、BRESP 稳定性、BRESP 合法值
- **读通道**: ARREADY 仅在 ARVALID 时拉高、握手后拉低、RVALID 持续到 RREADY、RDATA/RRESP 稳定性、RRESP 合法值
- **Cover**: AW/W/B/AR/R 五通道握手覆盖 + BRESP/RRESP 值覆盖

---

## 五、仿真运行

### 5.1 Makefile 命令

```bash
make build                          # 仅编译
make vcs TEST=axi_lite_test         # 编译+运行指定测试
make verdi                          # 打开 Verdi 波形查看
make cov                            # 生成覆盖率报告
make clean                          # 清理
```

### 5.2 回归测试

```bash
python3 regression.py               # 运行所有4个测试用例，结果存入 results/
python3 pass_rate.py sim.log        # 解析日志计算 scoreboard 读通过率
```

### 5.3 VCS 编译选项

- `-ntb_opts uvm-1.2` — UVM 1.2
- `-cm line+cond+fsm+tgl+branch+assert` — 全覆盖率收集
- `-debug_access+all` — 完整调试信息

---

## 六、形式验证

`fv/read_fv.sv` 包含读通道的 5 个形式验证属性:
1. ARREADY 最终会响应 ARVALID
2. RVALID 仅在有效读时拉高
3. RVALID+RREADY 握手后 RVALID 拉低
4. RRESP 值合法 (00 或 10)
5. RDATA 与 reg_file 内容一致

---

## 七、模块独立测试 (tb_module_check/)

| 测试 | DUT | 描述 |
|------|-----|------|
| `tb_decoder.sv` | address_decoder | 随机地址+边界条件测试 |
| `tb_read.sv` | read_channel | 有效/无效读请求+FSDB波形 |
| `tb_write.sv` | write_channel | 有效/无效写事务+bresp检查+FSDB波形 |
| `tb_top.sv` | axi_lite_slave (整体) | 写 DEADBEEFCAFEBABE + 读回验证+FSDB波形 |

---

## 八、已知设计特点与注意事项

1. **写通道要求 AW 和 W 同时就绪**: write_channel 在 IDLE 状态需要 awready 和 wready 同时为高才进入 WRITE_DATA。不支持 AW/W 通道独立握手后合并。
2. **Driver 中 reset 处理**: driver 使用 `fork-join` 同时监控 reset 和处理事务，通过 `in_reset` 标志实现中断/恢复。
3. **Scoreboard 按 64-bit 对齐**: 地址右移3位作为寄存器索引 (`addr >> 3`)。
4. **Coverage 采样在 subscriber 的 write 函数中**: 由 monitor 的 analysis_port 触发。
5. **axi_test_pkg.sv 中存在包名冲突**: 包名 `axi_seq_pkg` 与 `axi_seq_pkg.sv` 中的同名，当前通过 filelist.f 直接 include 绕过（包被注释掉了）。
6. **tb_top 中有 reset 抖动测试**: 先 reset→release→再 reset→release，测试 reset 恢复能力。
