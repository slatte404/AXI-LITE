#!/usr/bin/env python3
import os
import glob

RESULTS_DIR = "results"

def analyze_log(log_path):
    pass_count = 0
    fail_count = 0
    uvm_errors = 0
    uvm_fatals = 0
    
    try:
        with open(log_path, "r", encoding="utf-8", errors="ignore") as f:
            for line in f:
                if "UVM_ERROR " in line:
                    uvm_errors += 1
                if "UVM_FATAL " in line:
                    uvm_fatals += 1
                    
                # 兼容现有的 SCOREBOARD 打印格式
                if "SCOREBOARD" in line and "READ" in line:
                    if "PASS" in line:
                        pass_count += 1
                    elif "MISMATCH" in line or "FAIL" in line:
                        fail_count += 1
                        
    except Exception as e:
        print(f"Error reading {log_path}: {e}")
        
    return pass_count, fail_count, uvm_errors, uvm_fatals

def main():
    if not os.path.exists(RESULTS_DIR):
        print(f"[WARN] No results directory found at '{RESULTS_DIR}'. Please run tests first.")
        return

    # 自动扫描所有的 sim.log
    log_files = glob.glob(os.path.join(RESULTS_DIR, "*", "sim.log"))
    
    if not log_files:
        print("[WARN] No sim.log files found in results subdirectories.")
        return

    print("="*75)
    print(f"{'Test Folder (Test_Seed)':<30} | {'Read Pass':<10} | {'Read Fail':<10} | {'UVM Err/Fat':<15}")
    print("-" * 75)
    
    total_pass = 0
    total_fail = 0
    
    for log in sorted(log_files):
        test_dir_name = os.path.basename(os.path.dirname(log))
        p_cnt, f_cnt, u_err, u_fat = analyze_log(log)
        total_pass += p_cnt
        total_fail += f_cnt
        
        status_str = f"{u_err} / {u_fat}"
        print(f"{test_dir_name:<30} | {p_cnt:<10} | {f_cnt:<10} | {status_str:<15}")

    print("="*75)
    total_reads = total_pass + total_fail
    pass_rate = (total_pass / total_reads * 100) if total_reads > 0 else 0.0
    print(f"Global Read Pass Rate: {pass_rate:.2f}% ({total_pass}/{total_reads})")

if __name__ == "__main__":
    main()
