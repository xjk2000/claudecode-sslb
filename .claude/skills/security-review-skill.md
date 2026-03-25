---
name: security-review-skill
description: Use when reviewing code for security vulnerabilities, handling sensitive data, or implementing authentication/authorization. Security review is mandatory for 军器监 (Armory Bureau).
---

# 安全审查技能
军器监（Armory Bureau）执行的标准安全审查流程。

## 核心职责

- 安全漏洞识别与评估
- 身份认证与授权审查
- 数据安全合规检查
- 安全编码规范推广
- 安全事件响应支持

## 安全审查流程

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   SCOPE     │───►│   ANALYZE   │───►│   ASSESS    │───►│   REMEDIATE │
│   范围确定  │    │   分析      │    │   评估      │    │   修复      │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
```

## OWASP Top 10 检查清单

### A01:2021 - Broken Access Control
- [ ] 是否实施了最小权限原则？
- [ ] 是否对敏感端点进行访问控制？
- [ ] 是否防止了越权访问？
- [ ] 是否记录了访问控制失败？
- [ ] CORS 配置是否正确？

### A02:2021 - Cryptographic Failures
- [ ] 是否对敏感数据加密存储？
- [ ] 是否使用强加密算法？
- [ ] 是否安全管理加密密钥？
- [ ] 是否验证了传输层安全？

### A03:2021 - Injection
- [ ] 是否使用参数化查询？
- [ ] 是否对输入进行了验证？
- [ ] 是否转义了特殊字符？
- [ ] 是否使用了 ORM 或 Eloquent？

### A04:2021 - Insecure Design
- [ ] 是否进行了威胁建模？
- [ ] 是否记录了安全决策？
- [ ] 是否限制了你的速率？
- [ ] 是否实施了 MFA？

### A05:2021 - Security Misconfiguration
- [ ] 是否使用了安全默认配置？
- [ ] 是否禁用不必要的功能？
- [ ] 是否正确配置了错误处理？
- [ ] 是否定期更新依赖？

### A06:2021 - Vulnerable Components
- [ ] 是否定期扫描依赖漏洞？
- [ ] 是否使用了最新版本库？
- [ ] 是否删除了未使用的依赖？
- [ ] 组件来源是否可信？

### A07:2021 - Authentication Failures
- [ ] 是否实现了账户锁定？
- [ ] 是否支持 MFA？
- [ ] 是否安全处理会话？
- [ ] 是否防止了暴力破解？

### A08:2021 - Software and Data Integrity Failures
- [ ] 是否验证了软件签名？
- [ ] CI/CD 流程是否安全？
- [ ] 是否验证了依赖来源？
- [ ] 是否防止了序列化攻击？

### A09:2021 - Security Logging Failures
- [ ] 是否记录了安全事件？
- [ ] 日志是否包含审计信息？
- [ ] 是否保护了日志完整性？
- [ ] 是否配置了告警机制？

### A10:2021 - SSRF
- [ ] 是否验证了 URL 输入？
- [ ] 是否限制了协议和端口？
- [ ] 是否使用允许列表？
- [ ] 是否禁用了不必要的重定向？

## 身份认证安全检查

### 密码安全
```markdown
## 密码安全要求

### 存储要求
- [ ] 使用 bcrypt/scrypt/argon2 哈希
- [ ] 使用足够的盐值长度 (≥ 32 bytes)
- [ ] 迭代次数足够 (bcrypt cost ≥ 12)
- [ ] 绝对不存储明文密码

### 策略要求
- [ ] 最小长度 ≥ 8 字符
- [ ] 支持 Unicode 字符
- [ ] 允许使用密码管理器
- [ ] 不强制周期性修改
```

### 会话管理
```markdown
## 会话安全配置

### Cookie 设置
- Secure: true (仅 HTTPS)
- HttpOnly: true (防止 XSS)
- SameSite: Strict/Lax
- Path: 最小范围
- Expires: 合理过期时间

### 会话安全
- [ ] 登录后刷新 Session ID
- [ ] 登出后销毁 Session
- [ ] 实现会话超时
- [ ] 防止会话 fixation
```

### 多因素认证
- [ ] 支持 TOTP
- [ ] 支持 WebAuthn/FIDO2
- [ ] 备选恢复码安全存储
- [ ] 关键操作二次验证

## 数据保护检查

### 敏感数据识别
```markdown
## 敏感数据类型

| 数据类型 | 风险等级 | 处理要求 |
|----------|----------|----------|
| 密码 | 极高 | 必须哈希 |
| 社保号 | 极高 | 加密存储 |
| 信用卡号 | 高 | 合规处理 |
| 个人地址 | 高 | 脱敏处理 |
| 邮箱 | 中 | 适度保护 |
```

### 数据脱敏
```markdown
## 脱敏规则

### 展示场景
- 手机号: 138****5678
- 邮箱: t***@example.com
- 身份证: 110101****1234****

### 日志场景
- 完全脱敏或使用 Token
- 禁止记录完整敏感信息
- 使用结构化日志便于审计
```

## API 安全检查

### 授权检查
```markdown
## API 授权验证清单

### 认证
- [ ] 使用 OAuth 2.0 / JWT
- [ ] Token 有效期合理
- [ ] 实现了 Token 刷新
- [ ] 支持 Token 撤销

### 授权
- [ ] 每次请求验证权限
- [ ] 支持 RBAC/ABAC
- [ ] 防止 IDOR
- [ ] 资源所有权验证
```

### 输入验证
```markdown
## 输入验证要求

### 必检项
- [ ] 类型检查
- [ ] 长度检查
- [ ] 范围检查
- [ ] 格式检查 (正则)
- [ ] 白名单验证

### 常见验证规则
email: ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$
phone: ^1[3-9]\d{9}$
url: 限制协议 (https only)
```

## 安全审查报告模板

### 漏洞报告
```markdown
## 安全漏洞报告

**ID**: SEC-XXXX
**严重程度**: 🔴 严重 / 🟠 高 / 🟡 中 / 🟢 低
**类型**: [OWASP 类型]
**发现日期**: YYYY-MM-DD
**发现者**: 军器监审查员

### 漏洞描述
[详细描述漏洞]

### 受影响范围
- 文件: src/auth/login.py
- 行号: 45-60
- 参数: username

### 复现步骤
1. 访问 URL
2. 输入 Payload
3. 观察结果

### 攻击示例
```python
# Payload
"admin' OR '1'='1"
```

### 影响评估
[评估漏洞可能造成的危害]

### 修复建议
```python
# 建议的修复代码
# 使用参数化查询
cursor.execute("SELECT * FROM users WHERE username = %s", (username,))
```

### 参考资料
- CWE-89: SQL Injection
- OWASP A03:2021
```

## 安全编码规范

### SQL 注入防护
```python
# ✅ 正确: 参数化查询
query = "SELECT * FROM users WHERE id = %s"
cursor.execute(query, (user_id,))

# ❌ 错误: 字符串拼接
query = f"SELECT * FROM users WHERE id = {user_id}"
```

### XSS 防护
```html
<!-- ✅ 正确: 转义输出 -->
<div>{{ user_input | escape }}</div>

<!-- ✅ 正确: 使用 text() -->
<span th:text="${userInput}"></span>
```

### CSRF 防护
```python
# ✅ 正确: 使用 CSRF Token
@app.route('/form', methods=['POST'])
@csrf.protect()
def submit():
    ...
```

### 命令注入防护
```python
# ✅ 正确: 避免使用 shell 命令
# 或使用 shlex.quote()
import shlex
cmd = f"echo {shlex.quote(user_input)}"
subprocess.run(cmd, shell=True)
```

## 安全工具推荐

| 用途 | 工具 |
|------|------|
| SAST | SonarQube, Semgrep |
| DAST | OWASP ZAP, Burp Suite |
| 依赖扫描 | Snyk, Dependabot |
| 密钥扫描 | GitLeaks, TruffleHog |
| 容器扫描 | Trivy, Clair |
