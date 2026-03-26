#!/usr/bin/env bash
# 任务路由工具 - 根据任务类型和代码位置自动路由到对应部门
# 用法:
#   task-router.sh route <task_type> [file_path]
#   task-router.sh code-owner <file_path>
#   task-router.sh department <department_name>

set -euo pipefail

# 根据逻辑领域确定代码归属（五监角色）
# 注意：具体代码路径因项目而异，此处提供常见模式作为参考
# 尚书令会根据实际项目结构做最终判断
get_code_owner() {
    local filepath="$1"

    # 以下为常见项目结构的启发式匹配，不同项目可能不同
    case "$filepath" in
        *domain/*|*service/*|*core/*|*business/*|*usecase/*)
            echo "将作监（核心业务逻辑）"
            ;;
        *component/*|*page/*|*view/*|*ui/*|*frontend/*|*style/*|*css/*)
            echo "少府监（前端交互）"
            ;;
        *auth/*|*security/*|*crypto/*|*permission/*|*rbac/*)
            echo "军器监（安全认证）"
            ;;
        *data/*|*db/*|*migration/*|*model/*|*repositor/*|*mapper/*|*dao/*)
            echo "都水监（数据处理）"
            ;;
        *config/*|*infra/*|*framework/*|*middleware/*|*plugin/*)
            echo "国子监（框架架构）"
            ;;
        *test*|*spec/*)
            echo "兵部（测试）"
            ;;
        *doc*|*.md)
            echo "礼部（文档）"
            ;;
        *)
            echo "由尚书令根据逻辑领域判断"
            ;;
    esac
}

# 根据任务类型路由到部门
route_task() {
    local task_type="$1"
    local filepath="${2:-}"

    case "$task_type" in
        feature|新功能|implement|实现)
            if [ -n "$filepath" ]; then
                local owner
                owner=$(get_code_owner "$filepath")
                echo "{\"department\": \"尚书令\", \"implementer\": \"${owner}\", \"flow\": \"尚书令 → 制定计划 → dispatch(${owner})\"}"
            else
                echo "{\"department\": \"尚书令\", \"flow\": \"中书令brainstorming → 敕令拆解 → 侍中审议 → 尚书令计划 → 五监实现\"}"
            fi
            ;;
        bugfix|bug|调试|debug)
            if [ -n "$filepath" ]; then
                local owner
                owner=$(get_code_owner "$filepath")
                echo "{\"department\": \"刑部\", \"implementer\": \"${owner}\", \"flow\": \"刑部诊断 → 打回${owner}修复\"}"
            else
                echo "{\"department\": \"刑部\", \"flow\": \"刑部四阶段调试 → 打回五监修复\"}"
            fi
            ;;
        test|测试|tdd)
            if [ -n "$filepath" ]; then
                local owner
                owner=$(get_code_owner "$filepath")
                echo "{\"department\": \"兵部\", \"implementer\": \"${owner}\", \"flow\": \"兵部写测试 → 打回${owner}实现\"}"
            else
                echo "{\"department\": \"兵部\", \"flow\": \"兵部TDD → 打回五监实现\"}"
            fi
            ;;
        review|审查|code-review)
            echo "{\"department\": \"工部\", \"flow\": \"工部两阶段review（spec + quality）\"}"
            ;;
        refactor|重构)
            if [ -n "$filepath" ]; then
                local owner
                owner=$(get_code_owner "$filepath")
                echo "{\"department\": \"尚书令\", \"implementer\": \"${owner}\", \"flow\": \"尚书令计划 → ${owner}实现 → 工部review\"}"
            else
                echo "{\"department\": \"尚书令\", \"flow\": \"尚书令计划 → 五监实现 → 工部review\"}"
            fi
            ;;
        docs|文档)
            echo "{\"department\": \"尚书令\", \"flow\": \"尚书令直接处理文档任务\"}"
            ;;
        *)
            echo "{\"department\": \"中书令\", \"flow\": \"中书令分析任务类型后路由\"}"
            ;;
    esac
}

# 获取部门信息
get_department_info() {
    local dept="$1"

    case "$dept" in
        中书令|zhongshuling)
            cat << 'EOF'
{
  "name": "中书令",
  "role": "首席决策官",
  "province": "中书省",
  "skills": ["sslb:edict-decompose"],
  "responsibilities": ["需求探索", "敕令拆解", "任务路由"]
}
EOF
            ;;
        侍中|shizhong)
            cat << 'EOF'
{
  "name": "侍中",
  "role": "首席审核官",
  "province": "门下省",
  "skills": ["sslb:fengbo-review"],
  "responsibilities": ["敕令审议", "封驳把关", "交付验收"]
}
EOF
            ;;
        尚书令|shangshuling)
            cat << 'EOF'
{
  "name": "尚书令",
  "role": "首席调度官",
  "province": "尚书省",
  "skills": [],
  "responsibilities": ["制定计划", "dispatch执行", "协调进度"]
}
EOF
            ;;
        兵部|bingbu)
            cat << 'EOF'
{
  "name": "兵部",
  "role": "测试验证",
  "province": "尚书省·六部",
  "skills": ["sslb:dahui-dispatch"],
  "responsibilities": ["TDD测试", "打回五监"]
}
EOF
            ;;
        刑部|xingbu)
            cat << 'EOF'
{
  "name": "刑部",
  "role": "系统化调试",
  "province": "尚书省·六部",
  "skills": ["sslb:dahui-dispatch"],
  "responsibilities": ["根因分析", "打回五监"]
}
EOF
            ;;
        工部|gongbu)
            cat << 'EOF'
{
  "name": "工部",
  "role": "代码审查",
  "province": "尚书省·六部",
  "skills": ["sslb:dahui-dispatch"],
  "responsibilities": ["spec审查", "质量审查", "打回五监"]
}
EOF
            ;;
        五监|wujian)
            cat << 'EOF'
{
  "name": "五监",
  "role": "代码实现",
  "province": "尚书省·五监",
  "skills": [],
  "responsibilities": ["代码实现", "接收打回修复"],
  "sub_roles": {
    "将作监": "核心业务逻辑（业务规则、领域模型、业务服务）",
    "少府监": "前端交互（UI组件、页面、交互、样式）",
    "军器监": "安全认证（认证、授权、加密、安全审计）",
    "都水监": "数据处理（数据库、数据转换、数据校验）",
    "国子监": "框架架构（框架、中间件、配置、基础设施）"
  }
}
EOF
            ;;
        *)
            echo "{\"error\": \"未知部门: ${dept}\"}"
            ;;
    esac
}

# 主路由
case "${1:-help}" in
    route)
        shift
        route_task "$@"
        ;;
    code-owner)
        shift
        get_code_owner "${1:?用法: code-owner <file_path>}"
        ;;
    department)
        shift
        get_department_info "${1:?用法: department <department_name>}"
        ;;
    help|*)
        cat << 'HELP'
三省六部任务路由工具

用法:
  task-router.sh route <task_type> [file_path]
    根据任务类型路由到对应部门
    task_type: feature/bugfix/test/review/refactor/docs

  task-router.sh code-owner <file_path>
    根据文件路径确定代码归属（五监角色）

  task-router.sh department <name>
    获取部门详细信息
    name: 中书令/侍中/尚书令/兵部/刑部/工部/五监
HELP
        ;;
esac
