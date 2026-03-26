#!/usr/bin/env bash
# 三省六部 Agent Teams — 快速安装到 ~/.claude/
# 用法: bash install.sh
#
# 将 agents、commands、skills、tools 安装到 ~/.claude/ 目录，
# Claude Code 会自动加载该目录下的配置。

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_DIR="${SCRIPT_DIR}/claude"
TARGET_DIR="${HOME}/.claude"

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

info()  { echo -e "${CYAN}[三省六部]${NC} $*"; }
ok()    { echo -e "${GREEN}[三省六部]${NC} $*"; }
warn()  { echo -e "${YELLOW}[三省六部]${NC} $*"; }
err()   { echo -e "${RED}[三省六部]${NC} $*" >&2; }

# 检查源目录
if [ ! -d "${SOURCE_DIR}" ]; then
    err "找不到 claude/ 目录，请在项目根目录下运行此脚本。"
    exit 1
fi

DIRS=("agents" "commands" "skills" "tools")

info "安装目标: ${TARGET_DIR}"
echo ""

# 检查是否有冲突文件
has_conflict=false
for dir in "${DIRS[@]}"; do
    if [ -d "${TARGET_DIR}/${dir}" ]; then
        # 检查目标目录是否有非三省六部的文件
        existing_count=$(find "${TARGET_DIR}/${dir}" -maxdepth 1 -type f 2>/dev/null | wc -l | tr -d ' ')
        if [ "$existing_count" -gt 0 ]; then
            warn "目标目录 ${TARGET_DIR}/${dir}/ 已有 ${existing_count} 个文件"
            has_conflict=true
        fi
    fi
done

if [ "$has_conflict" = true ]; then
    echo ""
    warn "检测到已有文件，安装将覆盖同名文件（不会删除你自己的文件）。"
    read -rp "是否继续？[y/N] " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        info "已取消安装。"
        exit 0
    fi
    echo ""
fi

# 创建目录并复制文件
installed=0
for dir in "${DIRS[@]}"; do
    if [ ! -d "${SOURCE_DIR}/${dir}" ]; then
        continue
    fi

    mkdir -p "${TARGET_DIR}/${dir}"

    for file in "${SOURCE_DIR}/${dir}"/*; do
        [ -f "$file" ] || continue
        filename=$(basename "$file")
        cp "$file" "${TARGET_DIR}/${dir}/${filename}"
        installed=$((installed + 1))
    done

    # 给 tools 下的 sh 文件加执行权限
    if [ "$dir" = "tools" ]; then
        chmod +x "${TARGET_DIR}/${dir}"/*.sh 2>/dev/null || true
    fi
done

echo ""
ok "安装完成！共安装 ${installed} 个文件。"
echo ""
info "已安装内容："
for dir in "${DIRS[@]}"; do
    if [ -d "${TARGET_DIR}/${dir}" ]; then
        count=$(find "${TARGET_DIR}/${dir}" -maxdepth 1 -type f | wc -l | tr -d ' ')
        echo "  ${TARGET_DIR}/${dir}/  (${count} 个文件)"
    fi
done
echo ""
info "现在可以在任意项目中使用 @zhongshuling 等 Agent 了。"
info "卸载请运行: bash $(dirname "$0")/uninstall.sh"
