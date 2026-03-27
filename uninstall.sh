#!/usr/bin/env bash
# ============================================================================
# 三省六部 (SSLB) — 卸载脚本
# 1. 通过 claude plugin uninstall 卸载 plugin
# 2. 清理 marketplace 注册
# 3. 清理 plugin cache
# 4. 清理 ~/.claude/ 下的手动安装残留文件
# 使用方式: bash uninstall.sh
# 作者: XuJiaKai
# ============================================================================

set -euo pipefail

# ---------- 颜色 ----------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info()  { echo -e "${CYAN}[SSLB]${NC} $1"; }
ok()    { echo -e "${GREEN}[SSLB]${NC} $1"; }
warn()  { echo -e "${YELLOW}[SSLB]${NC} $1"; }
err()   { echo -e "${RED}[SSLB]${NC} $1"; }

# ---------- 路径 ----------
CLAUDE_HOME="${HOME}/.claude"
MARKETPLACE_NAME="sslb-marketplace"
PLUGIN_NAME="sslb"

# ---------- 前置检查 ----------
if [ ! -d "${CLAUDE_HOME}" ]; then
    err "未找到 ~/.claude/ 目录，无需卸载"
    exit 0
fi

echo ""
echo -e "${RED}╔══════════════════════════════════════════════╗${NC}"
echo -e "${RED}║       三省六部 Agent Teams — 卸载程序       ║${NC}"
echo -e "${RED}╚══════════════════════════════════════════════╝${NC}"
echo ""

# ---------- 确认 ----------
echo -e "${YELLOW}即将彻底卸载三省六部 (sslb)，包括:${NC}"
echo ""
echo "  1. 通过 claude plugin uninstall 卸载 plugin"
echo "  2. 清理 marketplace 注册 (known_marketplaces.json)"
echo "  3. 清理 plugin cache (plugins/cache/sslb-marketplace/)"
echo "  4. 清理 installed_plugins.json 中的 sslb 条目"
echo "  5. 清理 ~/.claude/ 下的手动安装残留文件"
echo "     - agents/ 中的 16 个 Agent 文件"
echo "     - commands/ 中的 6 个 Command 文件"
echo "     - skills/ 中的 5 个 sslb-* Skill 文件"
echo "     - tools/ 中的 3 个脚本文件"
echo "     - docs/huangdi/ 模板文件"
echo ""
read -p "确认卸载？(y/N) " confirm
if [[ ! "${confirm}" =~ ^[Yy]$ ]]; then
    info "已取消卸载"
    exit 0
fi
echo ""

# ============================================================================
# Step 1: 通过 claude 命令卸载 plugin
# ============================================================================
info "Step 1: 通过 claude plugin uninstall 卸载..."
if command -v claude &> /dev/null; then
    claude plugin uninstall "${PLUGIN_NAME}" 2>/dev/null && ok "  claude plugin uninstall 完成" || warn "  claude plugin uninstall 未成功（可能已卸载或未通过 plugin 安装）"
else
    warn "  未找到 claude 命令，跳过 plugin uninstall，将直接清理文件"
fi

# ============================================================================
# Step 2: 清理 installed_plugins.json 中的 sslb 条目
# ============================================================================
info "Step 2: 清理 installed_plugins.json..."
INSTALLED_FILE="${CLAUDE_HOME}/plugins/installed_plugins.json"
if [ -f "${INSTALLED_FILE}" ]; then
    # 删除所有 key 包含 sslb-marketplace 的条目
    UPDATED=$(python3 -c "
import json, sys
with open('${INSTALLED_FILE}') as f:
    d = json.load(f)
plugins = d.get('plugins', {})
keys_to_remove = [k for k in plugins if '${MARKETPLACE_NAME}' in k]
for k in keys_to_remove:
    del plugins[k]
json.dump(d, sys.stdout, indent=2)
" 2>/dev/null) && echo "${UPDATED}" > "${INSTALLED_FILE}" && ok "  已清理 installed_plugins.json" || warn "  清理 installed_plugins.json 失败，跳过"
else
    ok "  installed_plugins.json 不存在，跳过"
fi

# ============================================================================
# Step 3: 清理 known_marketplaces.json 中的 sslb-marketplace
# ============================================================================
info "Step 3: 清理 Marketplace 注册..."
MARKETPLACE_FILE="${CLAUDE_HOME}/plugins/known_marketplaces.json"
if [ -f "${MARKETPLACE_FILE}" ]; then
    UPDATED=$(python3 -c "
import json, sys
with open('${MARKETPLACE_FILE}') as f:
    d = json.load(f)
if '${MARKETPLACE_NAME}' in d:
    del d['${MARKETPLACE_NAME}']
json.dump(d, sys.stdout, indent=2)
" 2>/dev/null) && echo "${UPDATED}" > "${MARKETPLACE_FILE}" && ok "  已从 known_marketplaces.json 移除 '${MARKETPLACE_NAME}'" || warn "  清理 known_marketplaces.json 失败，跳过"
else
    ok "  known_marketplaces.json 不存在，跳过"
fi

# ============================================================================
# Step 4: 清理 plugin cache
# ============================================================================
info "Step 4: 清理 Plugin Cache..."
CACHE_DIR="${CLAUDE_HOME}/plugins/cache"

# 清理 sslb-marketplace cache
if [ -d "${CACHE_DIR}/${MARKETPLACE_NAME}" ]; then
    rm -rf "${CACHE_DIR}/${MARKETPLACE_NAME}"
    ok "  已删除 cache/${MARKETPLACE_NAME}/"
fi

# 清理临时安装目录 (temp_local_* 可能是 sslb 安装时生成的)
temp_count=0
for temp_dir in "${CACHE_DIR}"/temp_local_*; do
    if [ -d "${temp_dir}" ]; then
        # 检查是否包含 sslb 相关文件
        if [ -d "${temp_dir}/agents" ] && [ -f "${temp_dir}/agents/zhongshuling.md" ]; then
            rm -rf "${temp_dir}"
            ((temp_count++))
        fi
    fi
done
if [ ${temp_count} -gt 0 ]; then
    ok "  已清理 ${temp_count} 个 sslb 临时安装目录"
fi

# ============================================================================
# Step 5: 清理 ~/.claude/ 下的手动安装残留文件
# ============================================================================
info "Step 5: 清理手动安装残留文件..."

# ---------- 定义 sslb 文件清单 ----------
AGENT_FILES=(bingbu.md dushui_jian.md gongbu.md guozi_jian.md hubu.md
    jiangzuo_jian.md jishi.md junqi_jian.md libu_docs.md libu_hr.md
    shangshuling.md shaofu_jian.md shizhong.md xingbu.md zhongshuling.md
    zhongshushe.md)

COMMAND_FILES=(continue-edict.md debug.md init-dynasty.md new-edict.md
    review.md tdd.md)

SKILL_FILES=(sslb-dahui-dispatch.md sslb-edict-decompose.md
    sslb-fengbo-review.md sslb-huangdi-docs.md sslb-using-sslb.md)

TOOL_FILES=(edict-manager.sh task-router.sh init-project.sh)

DOC_FILES=(README.md TEMPLATE-edict.md)

# ---------- 删除函数 ----------
remove_files() {
    local dir="$1"
    shift
    local files=("$@")
    local count=0
    for file in "${files[@]}"; do
        if [ -f "${dir}/${file}" ]; then
            rm -f "${dir}/${file}"
            ((count++))
        fi
    done
    echo "${count}"
}

# 清理空目录
cleanup_empty_dir() {
    local dir="$1"
    if [ -d "${dir}" ] && [ -z "$(ls -A "${dir}" 2>/dev/null)" ]; then
        rmdir "${dir}" 2>/dev/null && ok "  ${dir#${CLAUDE_HOME}/} 目录已清空并移除" || true
    fi
}

# agents
count=$(remove_files "${CLAUDE_HOME}/agents" "${AGENT_FILES[@]}")
[ "${count}" -gt 0 ] && ok "  agents/: 已移除 ${count} 个文件"
cleanup_empty_dir "${CLAUDE_HOME}/agents"

# commands
count=$(remove_files "${CLAUDE_HOME}/commands" "${COMMAND_FILES[@]}")
[ "${count}" -gt 0 ] && ok "  commands/: 已移除 ${count} 个文件"
cleanup_empty_dir "${CLAUDE_HOME}/commands"

# skills
count=$(remove_files "${CLAUDE_HOME}/skills" "${SKILL_FILES[@]}")
[ "${count}" -gt 0 ] && ok "  skills/: 已移除 ${count} 个文件"
cleanup_empty_dir "${CLAUDE_HOME}/skills"

# tools
count=$(remove_files "${CLAUDE_HOME}/tools" "${TOOL_FILES[@]}")
[ "${count}" -gt 0 ] && ok "  tools/: 已移除 ${count} 个文件"
cleanup_empty_dir "${CLAUDE_HOME}/tools"

# docs/huangdi 模板
count=$(remove_files "${CLAUDE_HOME}/docs/huangdi" "${DOC_FILES[@]}")
[ "${count}" -gt 0 ] && ok "  docs/huangdi/: 已移除 ${count} 个模板"
cleanup_empty_dir "${CLAUDE_HOME}/docs/huangdi"
cleanup_empty_dir "${CLAUDE_HOME}/docs"

# .sslb-installed 安装标记
if [ -f "${CLAUDE_HOME}/.sslb-installed" ]; then
    rm -f "${CLAUDE_HOME}/.sslb-installed"
    ok "  .sslb-installed 安装标记已移除"
fi

ok "  残留文件清理完成"

# ============================================================================
# 完成
# ============================================================================
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║          ✅ 三省六部已彻底卸载！            ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════╝${NC}"
echo ""
warn "注意: 各项目中的 docs/huangdi/ 目录（敕令记录、部门文档）未被删除"
warn "如需清理项目记录，请手动执行: rm -rf <项目>/docs/huangdi/"
echo ""
