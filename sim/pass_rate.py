#!/usr/bin/env python3
import re
import sys

# 默认日志文件名
default_log_file = "vcs.log"

# 获取日志文件，如果命令行传了参数就用参数，否则用默认文件
if len(sys.argv) < 2:
    log_file = default_log_file
    print(f"No log file specified. Using default: {log_file}")
else:
    log_file = sys.argv[1]

pass_count = 0
fail_count = 0
fail_transactions = []  # 用于记录失败的事务

# 匹配 SCOREBOARD 的 READ PASS / READ FAIL 行
pattern = re.compile(
    r'\[SCOREBOARD\] READ (PASS|FAIL): addr=0x([0-9A-Fa-f]+) reg=(\d+) data=0x([0-9A-Fa-f]+)'
)

try:
    with open(log_file, "r") as f:
        for line in f:
            match = pattern.search(line)
            if match:
                result, addr, reg, data = match.groups()
                addr_int = int(addr, 16)
                data_int = int(data, 16)
                reg_int = int(reg)

                if result == "PASS":
                    pass_count += 1
                elif result == "FAIL":
                    fail_count += 1
                    # 记录失败事务
                    fail_transactions.append({
                        "addr": addr_int,
                        "reg": reg_int,
                        "data": data_int
                    })

    total = pass_count + fail_count
    pass_rate = (pass_count / total * 100) if total > 0 else 0.0

    print(f"Total READ transactions: {total}")
    print(f"PASS: {pass_count}")
    print(f"FAIL: {fail_count}")
    print(f"Pass rate: {pass_rate:.2f}%")

    if fail_transactions:
        print("\nFailed READ transactions:")
        for tr in fail_transactions:
            print(f"  addr=0x{tr['addr']:08X} reg={tr['reg']} data=0x{tr['data']:08X}")

except FileNotFoundError:
    print(f"Error: log file '{log_file}' not found.")
    sys.exit(1)


