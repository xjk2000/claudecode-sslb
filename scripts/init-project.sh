#!/usr/bin/env bash
# 三省六部 — 项目初始化脚本
# 在项目根目录创建 docs/huangdi/ 目录结构
# 由 SessionStart hook 自动调用，仅在目录不存在时执行

if [ -d "docs/huangdi/政事堂" ]; then
    exit 0
fi

mkdir -p docs/huangdi/{政事堂,秘书省,弘文馆,考功司,籍账库,职方司,都官司,礼部精舍,营缮司,将作图谱库,百工署,甲弩坊署,河渠书库,经籍库}

# 复制模板文件
if [ -n "${CLAUDE_PLUGIN_ROOT:-}" ] && [ -d "${CLAUDE_PLUGIN_ROOT}/templates/huangdi" ]; then
    for file in "${CLAUDE_PLUGIN_ROOT}/templates/huangdi"/*.md; do
        [ -f "$file" ] || continue
        filename=$(basename "$file")
        if [ ! -f "docs/huangdi/$filename" ]; then
            cp "$file" "docs/huangdi/$filename"
        fi
    done
fi

echo "三省六部：docs/huangdi/ 目录结构已创建"
