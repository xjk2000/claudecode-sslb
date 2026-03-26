#!/usr/bin/env bash
# 三省六部 Agent Teams — 快速卸载
# 用法: bash uninstall.sh
#
# 仅删除由三省六部安装的文件，不会误删你自己创建的文件。

set -euo pipefail

TARGET_DIR="${HOME}/.claude"

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info()  { echo -e "${CYAN}[三省六部]${NC} $*"; }
ok()    { echo -e "${GREEN}[三省六部]${NC} $*"; }
warn()  { echo -e "${YELLOW}[三省六部]${NC} $*"; }
err()   { echo -e "${RED}[三省六部]${NC} $*" >&2; }

# 三省六部安装的文件清单（精确匹配，避免误删）
AGENT_FILES=(
    "bingbu.md"
    "dushui_jian.md"
    "gongbu.md"
    "guozi_jian.md"
    "hubu.md"
    "jiangzuo_jian.md"
    "jishi.md"
    "junqi_jian.md"
    "libu_docs.md"
    "libu_hr.md"
    "shangshuling.md"
    "shaofu_jian.md"
    "shizhong.md"
    "xingbu.md"
    "zhongshuling.md"
    "zhongshushe.md"
)

COMMAND_FILES=(
    "debug.md"
    "new-edict.md"
    "review.md"
    "tdd.md"
)

SKILL_FILES=(
    "sslb-dahui-dispatch.md"
    "sslb-edict-decompose.md"
    "sslb-fengbo-review.md"
    "sslb-using-sslb.md"
)

TOOL_FILES=(
    "edict-manager.sh"
    "task-router.sh"
)

# 检查是否已安装
if [ ! -d "${TARGET_DIR}" ]; then
    warn "~/.claude/ 目录不存在，无需卸载。"
    exit 0
fi

# 统计要删除的文件
to_delete=0
for f in "${AGENT_FILES[@]}"; do
    [ -f "${TARGET_DIR}/agents/${f}" ] && to_delete=$((to_delete + 1))
done
for f in "${COMMAND_FILES[@]}"; do
    [ -f "${TARGET_DIR}/commands/${f}" ] && to_delete=$((to_delete + 1))
done
for f in "${SKILL_FILES[@]}"; do
    [ -f "${TARGET_DIR}/skills/${f}" ] && to_delete=$((to_delete + 1))
done
for f in "${TOOL_FILES[@]}"; do
    [ -f "${TARGET_DIR}/tools/${f}" ] && to_delete=$((to_delete + 1))
done

if [ "$to_delete" -eq 0 ]; then
    info "未检测到三省六部安装的文件，无需卸载。"
    exit 0
fi

info "将从 ${TARGET_DIR} 中删除 ${to_delete} 个三省六部文件："
echo ""

# 预览要删除的文件
for f in "${AGENT_FILES[@]}"; do
    [ -f "${TARGET_DIR}/agents/${f}" ] && echo "  agents/${f}"
done
for f in "${COMMAND_FILES[@]}"; do
    [ -f "${TARGET_DIR}/commands/${f}" ] && echo "  commands/${f}"
done
for f in "${SKILL_FILES[@]}"; do
    [ -f "${TARGET_DIR}/skills/${f}" ] && echo "  skills/${f}"
done
for f in "${TOOL_FILES[@]}"; do
    [ -f "${TARGET_DIR}/tools/${f}" ] && echo "  tools/${f}"
done

echo ""
read -rp "确认卸载？[y/N] " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    info "已取消卸载。"
    exit 0
fi

# 执行删除
deleted=0
for f in "${AGENT_FILES[@]}"; do
    if [ -f "${TARGET_DIR}/agents/${f}" ]; then
        rm "${TARGET_DIR}/agents/${f}"
        deleted=$((deleted + 1))
    fi
done
for f in "${COMMAND_FILES[@]}"; do
    if [ -f "${TARGET_DIR}/commands/${f}" ]; then
        rm "${TARGET_DIR}/commands/${f}"
        deleted=$((deleted + 1))
    fi
done
for f in "${SKILL_FILES[@]}"; do
    if [ -f "${TARGET_DIR}/skills/${f}" ]; then
        rm "${TARGET_DIR}/skills/${f}"
        deleted=$((deleted + 1))
    fi
done
for f in "${TOOL_FILES[@]}"; do
    if [ -f "${TARGET_DIR}/tools/${f}" ]; then
        rm "${TARGET_DIR}/tools/${f}"
        deleted=$((deleted + 1))
    fi
done

# 清理空目录（仅当目录为空时才删除）
for dir in agents commands skills tools; do
    if [ -d "${TARGET_DIR}/${dir}" ]; then
        if [ -z "$(ls -A "${TARGET_DIR}/${dir}" 2>/dev/null)" ]; then
            rmdir "${TARGET_DIR}/${dir}"
        fi
    fi
done

echo ""
ok "卸载完成！已删除 ${deleted} 个文件。"
