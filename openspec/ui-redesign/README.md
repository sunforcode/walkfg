# Walk App — UI 重设计工作空间

> 创建时间：2026-03-23

## 目标

利用 Google Stitch 重新设计全套 UI，并落地到 Flutter 代码。

- **设计工具**：[stitch.withgoogle.com](https://stitch.withgoogle.com/)
- **设计方向**：保留天空蓝 + 运动风格，精细化提升
- **参考品牌**：Strava、AllTrails、Apple Health
- **分工**：用户在 Stitch 操作 → AI 提供 Prompt + 落地 Flutter 代码

---

## 文档结构

```
ui-redesign/
├── README.md              ← 本文件，总索引
├── design-system.md       ← 设计系统（颜色/字体/间距/组件规范）
├── progress.md            ← 进度追踪表
├── pages/                 ← 页面功能列表（按模块）
│   ├── 00-navigation.md   ← 主框架 & 底部导航
│   ├── 01-home.md         ← 首页
│   ├── 02-route.md        ← 路线模块（发现/详情/搜索/收藏）
│   ├── 03-trip.md         ← 行程模块（详情/编辑/列表）
│   ├── 04-equipment.md    ← 装备模块
│   ├── 05-guide.md        ← 攻略模块
│   ├── 06-profile.md      ← 个人中心
│   └── 07-auth.md         ← 认证模块（登录/注册）
└── prompts/               ← Stitch Prompt 库（按页面）
    ├── 00-global-style.md ← 总体风格（第一步必须先输入）
    ├── 01-home.md
    ├── 02-route-discovery.md
    ├── 03-route-detail.md
    ├── 04-trip-detail.md
    ├── 05-equipment.md
    ├── 06-guide-detail.md
    └── 07-profile.md
```

---

## 使用流程

1. 打开 Stitch，新建项目
2. 输入 `prompts/00-global-style.md` 中的 Prompt，建立整体风格基调
3. 逐页添加画板，按 `prompts/` 目录顺序输入各页面 Prompt
4. 每页生成后截图发给 AI 确认，不满意则迭代 Prompt
5. 全部确认后导出 Figma 文件
6. AI 按 `progress.md` 中的顺序逐页落地 Flutter 代码

---

## 快速链接

- 设计系统 → [design-system.md](./design-system.md)
- 进度追踪 → [progress.md](./progress.md)
- 页面功能 → [pages/](./pages/)
- Stitch Prompts → [prompts/](./prompts/)
