#!/usr/bin/env python3
import subprocess
import os

# 测试用例列表
TESTS = ["axi_base_test", "axi_full_test", "axi_random_test", "axi_wraddr_test"]
# 每个测试跑的随机种子列表（扩大覆盖率）
SEEDS = [1, 2, 3] 
RESULTS_DIR = "results"

def run_command(cmd):
    result = subprocess.run(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    return result.returncode

def check_log_for_errors(log_file):
    if not os.path.exists(log_file):
        return "NO_LOG"
    
    with open(log_file, "r", encoding="utf-8", errors="ignore") as f:
        content = f.read()
        # 如果包含 FATAL 或 ERROR，直接判 FAIL
        if "UVM_FATAL" in content or "UVM_ERROR" in content:
            return "FAIL"
        # 否则假设 PASS (只要跑到结尾生成了 UVM 报告)
        if "UVM Report Summary" in content: 
            return "PASS"
    return "UNKNOWN"

def main():
    print("="*60)
    print("Starting Automated Python Regression (Multi-Seed)")
    print("="*60)
    
    # 1. 编译
    print("[INFO] Compiling design (make build) ...")
    if run_command("make build") != 0:
        print("[FATAL] Compilation failed! Check compile.log")
        return
        
    summary = []
    
    # 2. 遍历测试用例和种子跑仿真
    for test in TESTS:
        for seed in SEEDS:
            test_id = f"{test}_{seed}"
            print(f"[INFO] Running {test_id} ...")
            # 直接调用 Makefile 的 run 目标
            run_command(f"make run TEST={test} SEED={seed}")
            
            # 解析日志
            log_file = os.path.join(RESULTS_DIR, test_id, "sim.log")
            status = check_log_for_errors(log_file)
            summary.append((test_id, status))
            
    # 3. 打印精美的回归报告
    print("\n" + "="*60)
    print(f"{'Regression Summary':^60}")
    print("="*60)
    
    pass_count = sum(1 for _, status in summary if status == "PASS")
    
    for test_id, status in summary:
        # 在终端打印颜色 (绿/红)
        color = "\033[92m" if status == "PASS" else "\033[91m"
        reset = "\033[0m"
        print(f"  {test_id:<35} : {color}[ {status} ]{reset}")
        
    print("-" * 60)
    print(f"  Total: {len(summary):<5} |  Pass: {pass_count:<5} |  Fail: {len(summary) - pass_count:<5}")
    print("="*60)
    
    # 4. 生成覆盖率
    print("\n[INFO] Generating HTML Coverage Report...")
    run_command("make cov")

if __name__ == "__main__":
    main()
