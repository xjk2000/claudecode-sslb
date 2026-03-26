---
name: claudecode-sslb
description: "三省六部 Agent Teams — 基于唐代官制的 16 Agent 协作系统，适用于 Claude Code Agent Teams。"
author: XuJiaKai
---

# 三省六部 Agent Teams

基于唐代三省六部官制的 **16 Agent** 协作系统，为 Claude Code 提供结构化的多 Agent 治理框架。

**无外部依赖，开箱即用。**

## 核心理念

- **治理架构**：三省制衡（决策 → 审核 → 执行），避免单点决策失误
- **职责分离**：发现问题的人不修代码，修代码的人不做诊断
- **逻辑领域**：五监按业务逻辑而非文件路径划分，适配任何项目结构
- **敕令驱动**：所有任务以标准化敕令流转，有编号、优先级、验收标准
- **过程留痕**：所有敕令在政事堂留下完整记录，防止治理漂移

## 安装

```bash
# 全局安装（推荐，所有项目可用）
git clone https://github.com/xjk2000/claudecode-sslb.git
cd claudecode-sslb && bash install.sh

# 或单项目安装
cp -r claudecode-sslb/claude/ your-project/.claude/
```

## 16 Agent 体系

### 三省首脑（5个）— 决策、审核、调度

| Agent | 角色 |
|-------|------|
| 中书令 `@zhongshuling` | 首席决策官 — 需求探索、敕令拆解 |
| 中书舍人 `@zhongshushe` | 记录秘书 — 敕令文档化、编号追踪 |
| 侍中 `@shizhong` | 首席审核官 — 封驳审议、交付验收 |
| 给事中 `@jishi` | 细节审核官 — 技术风险评估 |
| 尚书令 `@shangshuling` | 首席调度官 — 判断协作Agent、制定计划、dispatch |

### 六部（6个）— 专业职能

| Agent | 职责 |
|-------|------|
| 吏部 `@libu_hr` | Agent能力评估、任务分配优化 |
| 户部 `@hubu` | 数据收集、分析、可视化 |
| 礼部 `@libu_docs` | 技术文档、API文档、知识库 |
| 兵部 `@bingbu` | TDD测试验证 → 打回五监 |
| 刑部 `@xingbu` | 四阶段系统调试 → 打回五监 |
| 工部 `@gongbu` | 两阶段代码审查 → 打回五监 |

### 五监（5个）— 代码实现（按逻辑领域路由）

| Agent | 逻辑领域 |
|-------|----------|
| 将作监 `@jiangzuo_jian` | 核心业务（业务规则、领域模型、业务服务） |
| 少府监 `@shaofu_jian` | 前端交互（UI组件、页面、样式） |
| 军器监 `@junqi_jian` | 安全认证（认证、授权、加密） |
| 都水监 `@dushui_jian` | 数据处理（数据库、数据转换、数据校验） |
| 国子监 `@guozi_jian` | 框架架构（框架、中间件、配置、基础设施） |

## 核心流程

```
用户指令
  → 中书令需求探索
  → 中书舍人文档化
  → 侍中(+给事中)封驳审议
  → 尚书令制定计划 & 判断协作Agent
  → dispatch: 五监实现 / 兵部TDD / 刑部调试 / 户部数据 / 礼部文档
  → 工部两阶段review
  → 侍中交付验收
  → 中书令汇报用户
```

## 四大独有机制

### 1. 敕令制度
所有任务以「敕令」形式流转，编号规则：

| 类型 | 编号格式 |
|------|----------|
| 中书敕令 | ZS-YYYYMMDD-XXX |
| 兵部打回 | BTD-YYYYMMDD-XXX |
| 刑部打回 | TIAO-YYYYMMDD-XXX |
| 工部打回 | GBR-YYYYMMDD-XXX |

### 2. 封驳机制
门下省侍中审议敕令，不合格则封驳打回中书令修改。给事中辅助做技术风险评估。

### 3. 打回机制
**发现问题的人不修代码，修代码的人不做诊断。**
- 兵部写失败测试 → 打回五监实现
- 刑部定位根因 → 打回五监修复
- 工部发现问题 → 打回五监改正

### 4. 过程记录（政事堂 / 弘文馆）
所有敕令在 `docs/huangdi/` 中留下完整生命周期记录：
- `zhengshitang/` — 政事堂：当前活跃敕令，**每次会话启动时先读取此目录恢复上下文**
- `hongwenguan/` — 弘文馆：已完成敕令归档，作为知识库
- 防止治理漂移：Agent 通过读取政事堂重新锚定角色和任务状态

## Skills

| Skill | 用途 | 使用者 |
|-------|------|--------|
| sslb:using-sslb | 会话启动指南（含治理铁律） | 系统 |
| sslb:huangdi-docs | 过程记录规范 | 所有Agent |
| sslb:edict-decompose | 敕令拆解 | 中书令 |
| sslb:fengbo-review | 封驳审议 | 侍中 |
| sslb:dahui-dispatch | 打回派发 | 兵部/刑部/工部 |

## Slash Commands

| 命令 | 用途 |
|------|------|
| `/new-edict` | 新功能/新需求（完整流程） |
| `/debug` | Bug 诊断修复 |
| `/review` | 代码审查 |
| `/tdd` | 测试驱动开发 |

## 快速入口

```
@zhongshuling 帮我分析这个需求        # 需求探索
@shangshuling 实现用户注册功能         # 自动判断协作Agent
@bingbu 为 UserService 写测试         # TDD
@xingbu 登录接口返回500               # 调试
@gongbu review 这次提交               # 代码审查
```
