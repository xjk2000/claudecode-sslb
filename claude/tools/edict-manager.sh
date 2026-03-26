#!/usr/bin/env bash
# 敕令管理工具 - 创建、查询、更新敕令状态
# 用法:
#   edict-manager.sh create <type> <priority> <title> <department>
#   edict-manager.sh list [status]
#   edict-manager.sh status <edict_id> <new_status>
#   edict-manager.sh get <edict_id>

set -euo pipefail

# 配置
EDICT_DIR="${EDICT_DIR:-$(pwd)/docs/edicts}"
HUANGDI_DIR="$(pwd)/docs/huangdi"
TEMPLATE_DIR="${HOME}/.claude/docs/huangdi"
DATE_PREFIX=$(date +%Y%m%d)

# 确保目录存在
mkdir -p "$EDICT_DIR"
mkdir -p "$EDICT_DIR/active"
mkdir -p "$EDICT_DIR/completed"
mkdir -p "$EDICT_DIR/rejected"

# 初始化项目级 docs/huangdi/ 目录结构
cmd_init() {
    if [ -d "$HUANGDI_DIR/zhengshitang" ]; then
        echo "docs/huangdi/ 目录结构已存在，跳过初始化。"
        return
    fi

    echo "正在创建 docs/huangdi/ 目录结构..."

    # 三省中枢
    mkdir -p "$HUANGDI_DIR/zhengshitang"
    mkdir -p "$HUANGDI_DIR/mishusheng"
    mkdir -p "$HUANGDI_DIR/hongwenguan"
    # 六部文档库
    mkdir -p "$HUANGDI_DIR/kaogongsi"
    mkdir -p "$HUANGDI_DIR/jizhangku"
    mkdir -p "$HUANGDI_DIR/zhifangsi"
    mkdir -p "$HUANGDI_DIR/duguansi"
    mkdir -p "$HUANGDI_DIR/libujingshe"
    mkdir -p "$HUANGDI_DIR/yingshansi"
    # 五监文档库
    mkdir -p "$HUANGDI_DIR/jiangzuotupuku"
    mkdir -p "$HUANGDI_DIR/baigongshu"
    mkdir -p "$HUANGDI_DIR/jianufangshu"
    mkdir -p "$HUANGDI_DIR/hequshuku"
    mkdir -p "$HUANGDI_DIR/jingjiku"

    # 复制模板文件（如果全局安装了模板）
    if [ -d "$TEMPLATE_DIR" ]; then
        for file in "$TEMPLATE_DIR"/*.md; do
            [ -f "$file" ] || continue
            filename=$(basename "$file")
            if [ ! -f "$HUANGDI_DIR/$filename" ]; then
                cp "$file" "$HUANGDI_DIR/$filename"
            fi
        done
    fi

    echo "✅ docs/huangdi/ 初始化完成！"
    echo ""
    echo "目录结构："
    echo "  docs/huangdi/"
    echo "  ├── zhengshitang/    政事堂（活跃敕令）"
    echo "  ├── mishusheng/      秘书省（历史敕令原件）"
    echo "  ├── hongwenguan/     弘文馆（敕令总结库）"
    echo "  ├── kaogongsi/       考功司（吏部）"
    echo "  ├── jizhangku/       籍账库（户部）"
    echo "  ├── zhifangsi/       职方司（兵部）"
    echo "  ├── duguansi/        都官司（刑部）"
    echo "  ├── libujingshe/     礼部精舍（礼部）"
    echo "  ├── yingshansi/      营缮司（工部）"
    echo "  ├── jiangzuotupuku/  将作图谱库（将作监）"
    echo "  ├── baigongshu/      百工署（少府监）"
    echo "  ├── jianufangshu/    甲弩坊署（军器监）"
    echo "  ├── hequshuku/       河渠书库（都水监）"
    echo "  └── jingjiku/        经籍库（国子监）"
}

# 获取今日序号
get_next_seq() {
    local prefix="$1"
    local count
    count=$(find "$EDICT_DIR" -name "${prefix}-${DATE_PREFIX}-*" -type f 2>/dev/null | wc -l | tr -d ' ')
    printf "%03d" $((count + 1))
}

# 创建敕令
cmd_create() {
    local type="${1:?用法: create <type> <priority> <title> <department>}"
    local priority="${2:?缺少优先级 (P0/P1/P2/P3)}"
    local title="${3:?缺少标题}"
    local department="${4:?缺少主责部门}"

    local prefix
    case "$type" in
        edict|feature|bugfix|refactor|review|docs)
            prefix="ZS"
            ;;
        test-bounce)
            prefix="BTD"
            ;;
        debug-bounce)
            prefix="TIAO"
            ;;
        review-bounce)
            prefix="GBR"
            ;;
        *)
            echo "错误: 未知类型 '$type'，可选: edict/feature/bugfix/refactor/review/docs/test-bounce/debug-bounce/review-bounce"
            exit 1
            ;;
    esac

    local seq
    seq=$(get_next_seq "$prefix")
    local edict_id="${prefix}-${DATE_PREFIX}-${seq}"
    local filename="$EDICT_DIR/active/${edict_id}.md"
    local now
    now=$(date '+%Y-%m-%d %H:%M:%S')

    cat > "$filename" << EOF
# ${edict_id}

**创建时间**: ${now}
**优先级**: ${priority}
**类型**: ${type}
**状态**: 待审议
**主责部门**: ${department}

## 任务概述
${title}

## 验收标准
- [ ] (待补充)

## 执行记录
| 时间 | 操作 | 操作人 |
|------|------|--------|
| ${now} | 创建敕令 | 中书令 |

## 打回记录
(无)
EOF

    echo "{\"edict_id\": \"${edict_id}\", \"file\": \"${filename}\", \"status\": \"created\"}"
}

# 列出敕令
cmd_list() {
    local status="${1:-all}"
    local dir

    case "$status" in
        active|待审议|执行中|待验证)
            dir="$EDICT_DIR/active"
            ;;
        completed|已完成)
            dir="$EDICT_DIR/completed"
            ;;
        rejected|已封驳)
            dir="$EDICT_DIR/rejected"
            ;;
        all)
            echo "=== 活跃敕令 ==="
            find "$EDICT_DIR/active" -name "*.md" -type f 2>/dev/null | sort | while read -r f; do
                local id
                id=$(basename "$f" .md)
                local prio
                prio=$(grep "^\*\*优先级\*\*:" "$f" | head -1 | sed 's/.*: //')
                local st
                st=$(grep "^\*\*状态\*\*:" "$f" | head -1 | sed 's/.*: //')
                local dept
                dept=$(grep "^\*\*主责部门\*\*:" "$f" | head -1 | sed 's/.*: //')
                echo "  ${id} [${prio}] ${st} → ${dept}"
            done

            echo ""
            echo "=== 已完成敕令 ==="
            find "$EDICT_DIR/completed" -name "*.md" -type f 2>/dev/null | sort | while read -r f; do
                local id
                id=$(basename "$f" .md)
                echo "  ${id}"
            done
            return
            ;;
        *)
            echo "错误: 未知状态 '$status'，可选: active/completed/rejected/all"
            exit 1
            ;;
    esac

    find "$dir" -name "*.md" -type f 2>/dev/null | sort | while read -r f; do
        local id
        id=$(basename "$f" .md)
        local prio
        prio=$(grep "^\*\*优先级\*\*:" "$f" | head -1 | sed 's/.*: //')
        local st
        st=$(grep "^\*\*状态\*\*:" "$f" | head -1 | sed 's/.*: //')
        echo "  ${id} [${prio}] ${st}"
    done
}

# 更新敕令状态
cmd_status() {
    local edict_id="${1:?用法: status <edict_id> <new_status>}"
    local new_status="${2:?缺少新状态}"
    local now
    now=$(date '+%Y-%m-%d %H:%M:%S')

    # 查找敕令文件
    local file
    file=$(find "$EDICT_DIR" -name "${edict_id}.md" -type f 2>/dev/null | head -1)

    if [ -z "$file" ]; then
        echo "错误: 未找到敕令 '${edict_id}'"
        exit 1
    fi

    # 更新状态
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/^\*\*状态\*\*: .*/\*\*状态\*\*: ${new_status}/" "$file"
    else
        sed -i "s/^\*\*状态\*\*: .*/\*\*状态\*\*: ${new_status}/" "$file"
    fi

    # 添加执行记录
    local record="| ${now} | 状态变更为: ${new_status} | system |"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "/^| 时间 | 操作 | 操作人 |/,/^$/{/^$/i\\
${record}
}" "$file"
    else
        sed -i "/^| 时间 | 操作 | 操作人 |/,/^$/{/^$/i\\${record}" "$file"
    fi

    # 移动到对应目录
    case "$new_status" in
        已完成)
            mv "$file" "$EDICT_DIR/completed/"
            ;;
        已封驳)
            mv "$file" "$EDICT_DIR/rejected/"
            ;;
    esac

    echo "{\"edict_id\": \"${edict_id}\", \"status\": \"${new_status}\", \"updated\": true}"
}

# 获取敕令详情
cmd_get() {
    local edict_id="${1:?用法: get <edict_id>}"

    local file
    file=$(find "$EDICT_DIR" -name "${edict_id}.md" -type f 2>/dev/null | head -1)

    if [ -z "$file" ]; then
        echo "错误: 未找到敕令 '${edict_id}'"
        exit 1
    fi

    cat "$file"
}

# 主路由
case "${1:-help}" in
    init)
        cmd_init
        ;;
    create)
        shift
        cmd_create "$@"
        ;;
    list)
        shift
        cmd_list "${1:-all}"
        ;;
    status)
        shift
        cmd_status "$@"
        ;;
    get)
        shift
        cmd_get "$@"
        ;;
    help|*)
        cat << 'HELP'
三省六部敕令管理工具

用法:
  edict-manager.sh init
    在当前项目根目录初始化 docs/huangdi/ 目录结构（首次使用时执行）

  edict-manager.sh create <type> <priority> <title> <department>
    创建新敕令
    type: edict/feature/bugfix/refactor/review/docs/test-bounce/debug-bounce/review-bounce
    priority: P0/P1/P2/P3

  edict-manager.sh list [status]
    列出敕令
    status: active/completed/rejected/all (默认 all)

  edict-manager.sh status <edict_id> <new_status>
    更新敕令状态
    new_status: 待审议/已放行/执行中/待验证/已完成/已封驳

  edict-manager.sh get <edict_id>
    查看敕令详情
HELP
        ;;
esac
