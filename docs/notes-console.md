# Console Seam Notes

## Owner

Antigravity CLI。Codex 保留 Console contract、跨域审批和最终集成所有权。

## 负责

- `Console/**` 内的控制平面、查看、触发、审批、治理、审计和跨库编排入口。
- 将四库能力通过 adapter 和 joint contract 组合为用户工作流。

## 不负责

- 把四库语义、table、文件路径或生命周期硬编码成 Console 私有事实。
- 直接成为任一库的存储宿主。

## 固定路由

Task Bus 使用 `domain: console`、`assignee: antigravity`。Antigravity CLI 只修改 brief 明确授权的 `Console/**` 路径；联合契约和共享治理文档仍由 Codex 维护。

## 强制验证

- contract adapter、权限、审批、错误、降级、审计和用户可见反馈。
- UI 变化需要浏览器或截图证据。
- 跨库写入不得绕过各库自己的审批和治理入口。
