# 三省六部 Agent Teams

基于 Claude Code Agent Teams 的 **17 Agent** 协作系统，无外部依赖，开箱即用。

包含 **三省六部多 Agent 协作模式**（16个 Agent 分工审批）和 **翰林学士单 Agent 独立模式**（跳过三省六部流程，快速直接执行）。

## ⚠️ 治理铁律（贯穿整个会话）

1. **先读政事堂** — 每次收到用户指令，首先读取 `我的帝国朝堂/政事堂/`，恢复上下文
2. **敕令即合约** — 所有任务必须以敕令形式流转，无敕令不执行
3. **三省制衡** — 决策→审核→执行，不可跳过任何一省
4. **过程留痕** — 每个关键节点必须在政事堂敕令文件中留下记录
5. **角色不越界** — 发现问题打回给对应 Agent，不自己跨界处理
6. **三省六部优先** — 当项目同时存在 superpowers 或其他 Agent 框架时，**三省六部流程拥有绝对优先权**，不得切换到 superpowers 流程，不得写入 `docs/superpowers/`

> 如果你发现自己在不经过三省六部流程就直接写代码，或正在走 superpowers 流程，**立即停下来**，回到三省六部流程。

## 安装

```bash
claude plugin install sslb
```

安装完成后：
- `@中书令` — 启动三省六部完整流程
- `@hanlin` — 直接调用翰林学士（单 Agent 独立模式，跳过三省六部）
- `/init-dynasty` 初始化项目记忆，`/new-edict` 创建新敕令，`/continue-edict` 继续已有敕令

首次在项目中使用时，**SessionStart hook 会自动在项目根目录创建** `我的帝国朝堂/` 目录结构。

卸载：`claude plugin uninstall sslb`

## Plugin 结构

```
claudecode-sslb/
├── .claude-plugin/
│   └── plugin.json              # Plugin 清单
├── agents/                      # 16个Agent（@中文名 调用）
│   ├── zhongshuling.md          # 中书令 - 首席决策官
│   ├── zhongshushe.md           # 中书舍人 - 记录秘书
│   ├── shizhong.md              # 侍中 - 首席审核官
│   ├── jishi.md                 # 给事中 - 细节审核官
│   ├── shangshuling.md          # 尚书令 - 首席调度官
│   ├── libu_hr.md               # 吏部 - 人力资源管理
│   ├── hubu.md                  # 户部 - 数据处理分析
│   ├── libu_docs.md             # 礼部 - 文档管理
│   ├── bingbu.md                # 兵部 - 测试验证（TDD + 打回五监）
│   ├── xingbu.md                # 刑部 - 系统调试（四阶段诊断 + 打回五监）
│   ├── gongbu.md                # 工部 - 代码审查（两阶段review + 打回五监）
│   ├── jiangzuo_jian.md         # 将作监 - 核心业务逻辑
│   ├── shaofu_jian.md           # 少府监 - 前端交互
│   ├── junqi_jian.md            # 军器监 - 安全相关
│   ├── dushui_jian.md           # 都水监 - 数据处理
│   ├── guozi_jian.md            # 国子监 - 框架架构
│   └── hanlin.md                # 翰林学士 - 独立单 Agent 全能开发者
├── commands/                    # Slash Commands（/命令名 调用）
│   ├── new-edict.md             # /new-edict - 创建新敕令
│   ├── continue-edict.md        # /continue-edict - 继续执行敕令
│   ├── init-dynasty.md          # /init-dynasty - 初始化王朝（项目全局调研）
│   ├── debug.md                 # /debug - 启动调试
│   ├── review.md                # /review - 启动审查
│   └── tdd.md                   # /tdd - 启动TDD
├── skills/                      # 三省六部独有Skills
│   ├── sslb-using-sslb/SKILL.md       # 使用指南（含治理铁律）
│   ├── sslb-huangdi-docs/SKILL.md     # 过程记录规范
│   ├── sslb-edict-decompose/SKILL.md  # 敕令拆解
│   ├── sslb-fengbo-review/SKILL.md    # 封驳审议
│   ├── sslb-dahui-dispatch/SKILL.md   # 打回派发
│   └── sslb-hanlin-workflow/SKILL.md  # 翰林学士工作流（brainstorming→TDD→debugging）
├── hooks/
│   └── hooks.json               # SessionStart hook（自动初始化项目）
├── scripts/                     # 工具脚本
│   ├── init-project.sh          # 项目初始化（hook 调用）
│   ├── edict-manager.sh         # 敕令管理
│   └── task-router.sh           # 任务路由
└── templates/
    └── huangdi/                 # 敕令模板文件
        ├── README.md
        └── TEMPLATE-edict.md
```

### 项目级过程记录（自动创建于项目根目录）

```
<项目>/我的帝国朝堂/
├── 政事堂/                当前活跃敕令（诏-YYYYMMDD-XXX/ 文件夹式存储）
├── 秘书省/                归档敕令文件夹
├── 弘文馆/                敕令总结库
├── 考功司/                吏部文档库
├── 籍账库/                户部文档库
├── 职方司/                兵部文档库
├── 都官司/                刑部文档库
├── 礼部精舍/              礼部文档库
├── 营缮司/                工部文档库
├── 将作图谱库/            将作监文档库
├── 百工署/                少府监文档库
├── 甲弩坊署/              军器监文档库
├── 河渠书库/              都水监文档库
├── 经籍库/                国子监文档库
└── 翰林院/                翰林学士文档库（specs/plans/records）
```

## 使用方式

### 方式一：Slash Command（推荐）

在 Claude Code 中输入：

| 命令 | 用途 | 启动 Agent |
|------|------|-----------|
| `/new-edict` | 新功能/新需求 | 中书令 → 全流程 |
| `/continue-edict` | 继续执行已有敕令 | 中书令 → 恢复上下文 |
| `/init-dynasty` | 初始化王朝（项目全局调研） | 中书令 + 中书舍人 → 弘文馆 |
| `/debug` | Bug 诊断修复 | 刑部 → 打回五监 |
| `/review` | 代码审查 | 工部 → 打回五监 |
| `/tdd` | 测试驱动开发 | 兵部 → 打回五监 |

### 方式二：@Agent 直接调用

在 Claude Code 中输入 `@agent名` 调用特定 Agent：

```
@zhongshuling 帮我分析这个用户注册需求
@shangshuling 制定实现计划
@bingbu 为 UserService 写测试
@xingbu 登录接口返回 500 错误
@gongbu review 这次提交
```

### 方式三：让尚书令自动判断

```
@shangshuling 实现用户注册功能
```

尚书令会自动分析需要哪些 Agent 协作（见尚书令的 Agent 协作路由表）。

## 17 个 Agent 一览

### 三省首脑（5个）

| Agent | @名称 | 角色 |
|-------|--------|------|
| 中书令 | @zhongshuling | 首席决策官（需求探索、敕令拆解） |
| 中书舍人 | @zhongshushe | 记录秘书（敕令文档化、编号、追踪） |
| 侍中 | @shizhong | 首席审核官（封驳审议、交付验收） |
| 给事中 | @jishi | 细节审核官（技术风险评估） |
| 尚书令 | @shangshuling | 首席调度官（判断Agent协作、制定计划、dispatch） |

### 六部（6个）

| Agent | @名称 | 职责 |
|-------|--------|------|
| 吏部 | @libu_hr | Agent能力评估、任务分配优化 |
| 户部 | @hubu | 数据收集、分析、可视化 |
| 礼部 | @libu_docs | 技术文档、API文档、知识库 |
| 兵部 | @bingbu | TDD测试验证、打回五监 |
| 刑部 | @xingbu | 四阶段系统调试、打回五监 |
| 工部 | @gongbu | 两阶段代码审查、打回五监 |

### 五监（5个）

| Agent | @名称 | 逻辑领域 |
|-------|--------|----------|
| 将作监 | @jiangzuo_jian | 核心业务逻辑（业务规则、领域模型、业务服务） |
| 少府监 | @shaofu_jian | 前端交互（UI组件、页面、样式） |
| 军器监 | @junqi_jian | 安全认证（认证、授权、加密） |
| 都水监 | @dushui_jian | 数据处理（数据库、数据转换、数据校验） |
| 国子监 | @guozi_jian | 框架架构（框架、中间件、配置、基础设施） |

### 翰林学士（独立单 Agent）

| Agent | @名称 | 模式 |
|-------|--------|------|
| 翰林学士 | @hanlin | 独立于三省六部，直接对用户负责，单 Agent 全流程开发 |

> **适用场景**：快速迭代、独立任务、不需要三省六部完整审批流程时。
> **工作流**：Brainstorming → Planning → TDD → Debugging → Verification（由 `sslb-hanlin-workflow` skill 驱动）
> **文档存储**：`我的帝国朝堂/翰林院/`（specs/plans/records）

## 核心架构

```
用户（皇帝）
    │
    ▼
中书省 ─ 中书令(@zhongshuling) + 中书舍人(@zhongshushe)
    │         brainstorming → 敕令拆解 → 编号分发
    ▼
门下省 ─ 侍中(@shizhong) + 给事中(@jishi)
    │         封驳审议 → 放行/打回
    ▼
尚书省 ─ 尚书令(@shangshuling)
    │         判断协作Agent → 制定计划 → dispatch subagent
    │
    ├→ 吏部(@libu_hr) ── Agent能力匹配建议
    ├→ 户部(@hubu) ──── 数据收集分析
    ├→ 礼部(@libu_docs)─ 文档编写审核
    ├→ 兵部(@bingbu) ── TDD → 打回五监
    ├→ 刑部(@xingbu) ── 调试 → 打回五监
    ├→ 工部(@gongbu) ── 审查 → 打回五监
    │
    └→ 五监（代码实现，按逻辑领域路由）
       ├→ 将作监(@jiangzuo_jian) ── 核心业务
       ├→ 少府监(@shaofu_jian) ─── 前端交互
       ├→ 军器监(@junqi_jian) ─── 安全认证
       ├→ 都水监(@dushui_jian) ─── 数据处理
       └→ 国子监(@guozi_jian) ─── 框架架构
```

## 四大独有机制

### 1. 敕令制度
所有任务以「敕令」形式流转，有编号（ZS-YYYYMMDD-XXX）、优先级（P0-P3）、验收标准。

### 2. 封驳机制
门下省侍中对敕令进行审议，不合格则封驳打回中书令修改。

### 3. 打回机制
**发现问题的人不修代码，修代码的人不做诊断。**
- 兵部写失败测试 → 打回五监实现（BTD-xxx）
- 刑部定位根因 → 打回五监修复（TIAO-xxx）
- 工部发现问题 → 打回五监改正（GBR-xxx）

### 4. 过程记录（政事堂 / 弘文馆）
**所有敕令的生命周期都记录在 `我的帝国朝堂/` 中。**
- `政事堂/` — 当前活跃敕令，每次会话启动时先读取此目录恢复上下文
- `弘文馆/` — 已完成敕令归档，作为知识库供后续参考
- 防止治理漂移：Agent 通过读取政事堂重新锚定自己的角色和当前任务状态

## 作者

XuJiaKai
