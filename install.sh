#!/usr/bin/env bash
# ============================================================================
# 三省六部 (SSLB) — 安装脚本
# 通过 Claude Code Plugin Marketplace 机制安装
# 使用方式: bash install.sh
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
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_HOME="${HOME}/.claude"
MARKETPLACE_NAME="sslb-marketplace"
PLUGIN_NAME="sslb"

# ---------- 前置检查 ----------
if [ ! -f "${SCRIPT_DIR}/.claude-plugin/plugin.json" ]; then
    err "请在 claudecode-sslb 项目根目录下运行此脚本"
    exit 1
fi

if ! command -v claude &> /dev/null; then
    err "未找到 claude 命令，请先安装 Claude Code"
    err "参考: https://docs.anthropic.com/en/docs/claude-code"
    exit 1
fi

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║       三省六部 Agent Teams — 安装程序       ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════╝${NC}"
echo ""

# ---------- Step 1: 注册本地 Marketplace ----------
info "Step 1: 注册本地 Marketplace..."

MARKETPLACE_FILE="${CLAUDE_HOME}/plugins/known_marketplaces.json"
mkdir -p "${CLAUDE_HOME}/plugins"

# 读取现有 marketplace 配置，如果没有则创建空对象
if [ -f "${MARKETPLACE_FILE}" ]; then
    EXISTING=$(cat "${MARKETPLACE_FILE}")
else
    EXISTING="{}"
fi

# 检查是否已注册
if echo "${EXISTING}" | python3 -c "import sys,json; d=json.load(sys.stdin); sys.exit(0 if '${MARKETPLACE_NAME}' in d else 1)" 2>/dev/null; then
    ok "  Marketplace '${MARKETPLACE_NAME}' 已注册，跳过"
else
    # 将当前项目目录注册为本地 marketplace
    UPDATED=$(echo "${EXISTING}" | python3 -c "
import sys, json
from datetime import datetime, timezone
d = json.load(sys.stdin)
d['${MARKETPLACE_NAME}'] = {
    'source': {
        'source': 'local',
        'path': '${SCRIPT_DIR}'
    },
    'installLocation': '${SCRIPT_DIR}',
    'lastUpdated': datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%S.000Z')
}
json.dump(d, sys.stdout, indent=2)
")
    echo "${UPDATED}" > "${MARKETPLACE_FILE}"
    ok "  Marketplace '${MARKETPLACE_NAME}' 已注册 → ${SCRIPT_DIR}"
fi

# ---------- Step 2: 通过 claude 命令安装 Plugin ----------
info "Step 2: 安装 Plugin '${PLUGIN_NAME}'..."
info "  执行: claude plugin install ${PLUGIN_NAME} --marketplace ${MARKETPLACE_NAME}"
echo ""

claude plugin install "${PLUGIN_NAME}" --marketplace "${MARKETPLACE_NAME}"

# ---------- 完成 ----------
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║          ✅ 三省六部安装完成！              ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════╝${NC}"
echo ""
info "Plugin 组件:"
info "  agents/    — 16 个 Agent（@中书令 等）"
info "  commands/  — 6 个 Slash Command（/new-edict 等）"
info "  skills/    — 5 个 Skill"
info "  hooks/     — SessionStart 自动初始化"
info "  scripts/   — 敕令管理、任务路由"
echo ""
info "快速开始:"
info "  /init-dynasty     — 初始化王朝（首次使用推荐）"
info "  /new-edict        — 创建新敕令"
info "  /continue-edict   — 继续执行已有敕令"
info "  @zhongshuling     — 直接调用中书令"
echo ""
info "卸载: bash ${SCRIPT_DIR}/uninstall.sh"
echo ""
