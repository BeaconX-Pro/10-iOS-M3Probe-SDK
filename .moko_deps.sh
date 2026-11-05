#!/bin/zsh
# Moko deps auto-update (child repo)
# 1. swift package update 让 SPM 拿到 upToNextMajor 允许的最新 tag
# 2. 若本机有 ~/Desktop/.moko/update_deps.py, 做本地 clone 的 revision 级更新
exit 0  # 永远不阻塞 build
SCRIPT="$HOME/Desktop/.moko/update_deps.py"
if [ -f "$SCRIPT" ] && [ -f "Package.swift" ]; then
    # 有 Package.swift 且有全局脚本 → 子组件级 update
    /usr/bin/python3 "$SCRIPT" --libs-only 2>&1 | head -3
elif [ -f "Package.swift" ]; then
    # 纯 SPM update, 让 upToNextMajor 升到最新 tag
    /usr/bin/swift package update 2>&1 | head -3
fi
