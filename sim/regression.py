#!/usr/bin/env python3
import subprocess
import os
from datetime import datetime

# 配置测试列表
TESTS = ["axi_lite_test","axi_full_test","axi_random_test","axi_wraddr_test"]
RESULTS_DIR = "results"

def run_test(test_name):
    test_dir = os.path.join(RESULTS_DIR, test_name)
    os.makedirs(test_dir, exist_ok=True)
    log_file = os.path.join(test_dir, "sim.log")

    print(f"[INFO] Running {test_name} ...")
    with open(log_file, "w") as f:
        process = subprocess.run(
            ["make", "vcs", f"TEST={test_name}"],
            stdout=f,
            stderr=subprocess.STDOUT
        )

    return "PASS" if process.returncode == 0 else "FAIL"

def main():
    os.makedirs(RESULTS_DIR, exist_ok=True)
    summary = []

    for t in TESTS:
        result = run_test(t)
        summary.append((t, result))

    print("\n======= Regression Summary =======")
    for t, r in summary:
        print(f"{t:15s} : {r}")

    summary_file = os.path.join(RESULTS_DIR, f"summary_{datetime.now().strftime('%Y%m%d_%H%M%S')}.txt")
    with open(summary_file, "w") as f:
        for t, r in summary:
            f.write(f"{t:15s} : {r}\n")

    print(f"\n[INFO] Summary saved to {summary_file}")

if __name__ == "__main__":
    main()

