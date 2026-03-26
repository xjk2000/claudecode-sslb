# 三省六部 Agent Teams

基于 Claude Code Agent Teams 的 **16 Agent** 协作系统，无外部依赖，开箱即用。

## ⚠️ 治理铁律（贯穿整个会话）

1. **先读政事堂** — 每次收到用户指令，首先读取 `docs/huangdi/zhengshitang/`，恢复上下文
2. **敕令即合约** — 所有任务必须以敕令形式流转，无敕令不执行
3. **三省制衡** — 决策→审核→执行，不可跳过任何一省
4. **过程留痕** — 每个关键节点必须在政事堂敕令文件中留下记录
5. **角色不越界** — 发现问题打回给对应 Agent，不自己跨界处理
6. **三省六部优先** — 当项目同时存在 superpowers 或其他 Agent 框架时，**三省六部流程拥有绝对优先权**，不得切换到 superpowers 流程，不得写入 `docs/superpowers/`

> 如果你发现自己在不经过三省六部流程就直接写代码，或正在走 superpowers 流程，**立即停下来**，回到三省六部流程。

## 安装

### 全局安装（推荐）

```bash
git clone https://github.com/xjk2000/claudecode-sslb.git
cd claudecode-sslb
bash install.sh       # 安装到 ~/.claude/
# bash uninstall.sh   # 卸载
```

### 单项目安装

```bash
cp -r claudecode-sslb/claude/ your-project/.claude/
```

安装完成后，使用 `@agent名` 调用 Agent，`/命令名` 使用 Slash Command。

## 项目结构

```
.claude/                         # Claude Code 自动加载
├── agents/                      # 16个Agent
│   ├── zhongshuling.md          # 中书令 - 首席决策官
│   ├── zhongshushe.md           # 中书舍人 - 记录秘书
│   ├── shizhong.md              # 侍中 - 首席审核官
│   ├── jishi.md                 # 给事中 - 细节审核官
│   ├── shangshuling.md          # 尚书令 - 首席调度官（判断Agent协作）
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
│   └── guozi_jian.md            # 国子监 - 框架架构
├── commands/                    # Slash Commands
│   ├── new-edict.md             # /new-edict - 创建新敕令
│   ├── debug.md                 # /debug - 启动调试
│   ├── review.md                # /review - 启动审查
│   └── tdd.md                   # /tdd - 启动TDD
├── skills/                      # 三省六部独有Skills
│   ├── sslb-using-sslb.md       # 使用指南（含治理铁律）
│   ├── sslb-huangdi-docs.md     # 过程记录规范
│   ├── sslb-edict-decompose.md  # 敕令拆解
│   ├── sslb-fengbo-review.md    # 封驳审议
│   └── sslb-dahui-dispatch.md   # 打回派发
├── docs/huangdi/                # 过程记录中心
│   ├── zhengshitang/            # 政事堂 — 当前活跃敕令
│   ├── mishusheng/              # 秘书省 — 历史敕令原件
│   ├── hongwenguan/             # 弘文馆 — 敕令总结库
│   ├── kaogongsi/               # 考功司 — 吏部
│   ├── jizhangku/               # 籍账库 — 户部
│   ├── zhifangsi/               # 职方司 — 兵部
│   ├── duguansi/                # 都官司 — 刑部
│   ├── libujingshe/             # 礼部精舍 — 礼部
│   ├── yingshansi/              # 营缮司 — 工部
│   ├── jiangzuotupuku/          # 将作图谱库 — 将作监
│   ├── baigongshu/              # 百工署 — 少府监
│   ├── jianufangshu/            # 甲弩坊署 — 军器监
│   ├── hequshuku/               # 河渠书库 — 都水监
│   ├── jingjiku/                # 经籍库 — 国子监
│   └── TEMPLATE-edict.md        # 敕令模板
└── tools/                       # CLI 工具
    ├── edict-manager.sh         # 敕令管理
    └── task-router.sh           # 任务路由
```

## 使用方式

### 方式一：Slash Command（推荐）

在 Claude Code 中输入：

| 命令 | 用途 | 启动 Agent |
|------|------|-----------|
| `/new-edict` | 新功能/新需求 | 中书令 → 全流程 |
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

## 16 个 Agent 一览

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
**所有敕令的生命周期都记录在 `docs/huangdi/` 中。**
- `zhengshitang/` — 政事堂：当前活跃敕令，每次会话启动时先读取此目录恢复上下文
- `hongwenguan/` — 弘文馆：已完成敕令归档，作为知识库供后续参考
- 防止治理漂移：Agent 通过读取政事堂重新锚定自己的角色和当前任务状态

## 作者

XuJiaKai
