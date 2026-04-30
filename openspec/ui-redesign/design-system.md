# 设计系统（Design System）

> 所有 UI 代码必须通过 Token 引用，禁止硬编码样式值。

---

## 颜色（Colors）

### 主色 — 天空蓝
| Token | 值 | 用途 |
|---|---|---|
| `primary` | #2196F3 | 主色，按钮/链接/激活态 |
| `primaryLight` | #64B5F6 | 主色浅，背景填充 |
| `primaryDark` | #1976D2 | 主色深，按压态 |
| `onPrimary` | #FFFFFF | 主色上的文字/图标 |
| `primaryContainer` | #E3F2FD | 主色容器背景 |

### 辅助色 — 自然绿
| Token | 值 | 用途 |
|---|---|---|
| `secondary` | #4CAF50 | 行程卡片/成功状态 |
| `secondaryLight` | #81C784 | 辅助色浅 |
| `secondaryDark` | #388E3C | 辅助色深 |

### 强调色
| Token | 值 | 用途 |
|---|---|---|
| `accent` | #FF9800 | 橙色，警示/难度标签 |

### 语义色
| Token | 值 | 用途 |
|---|---|---|
| `success` | #4CAF50 | 成功状态 |
| `warning` | #FF9800 | 警告状态 |
| `error` | #F44336 | 错误状态 |
| `info` | #2196F3 | 信息提示 |

### 中性色
| Token | 值 | 用途 |
|---|---|---|
| `background` | #FAFAFA | 页面背景 |
| `surface` | #FFFFFF | 卡片/组件背景 |
| `card` | #FFFFFF | 卡片背景 |
| `border` | #E0E0E0 | 边框/分割线 |
| `divider` | #E0E0E0 | 分割线 |
| `textPrimary` | #212121 | 主文字 |
| `textSecondary` | #757575 | 次要文字 |
| `textHint` | #BDBDBD | 占位文字 |
| `iconPrimary` | #212121 | 主图标 |
| `iconSecondary` | #757575 | 次要图标 |

### 天气渐变色
| 天气 | 渐变 | 用途 |
|---|---|---|
| 晴天 | #FF9800 → #F57C00 | 温暖阳光 |
| 多云 | #90A4AE → #546E7A | 中性温和 |
| 下雨 | #2196F3 → #1565C0 | 冷调潮湿 |
| 下雪 | #B3E5FC → #4FC3F7 | 清冷纯洁 |
| 有雾 | #78909C → #455A64 | 模糊暗沉 |
| 默认 | #2196F3 → #1976D2 | 与主色统一 |

### 行程颜色调色板（Trip Colors）
索引 0–5 循环使用：`#388E3C` / `#4CAF50` / `#66BB6A` / `#81C784` / `#1B5E20` / `#00C853`

---

## 字体（Typography）

字体：**SF Pro Text**（系统字体）

### 展示级
| Token | 字号 | 字重 | 用途 |
|---|---|---|---|
| `displayLarge` | 32sp | w700 | 大标题 |
| `displayMedium` | 28sp | w700 | 中标题 |
| `displaySmall` | 24sp | w600 | 小标题 |

### 标题级
| Token | 字号 | 字重 | 用途 |
|---|---|---|---|
| `headlineLarge` | 22sp | w600 | 页面标题 |
| `headlineMedium` | 20sp | w600 | 区块标题 |
| `headlineSmall` | 18sp | w600 | 卡片标题 |

### 正文级
| Token | 字号 | 字重 | 用途 |
|---|---|---|---|
| `bodyLarge` | 16sp | w400 | 大段落 |
| `bodyMedium` | 14sp | w400 | 段落 |
| `bodySmall` | 12sp | w400 | 小段落 |

### 标签级
| Token | 字号 | 字重 | 用途 |
|---|---|---|---|
| `labelLarge` | 14sp | w500 | 大标签 |
| `labelMedium` | 12sp | w500 | 标签 |
| `labelSmall` | 10sp | w400 | 小标签/Tab |

### 数据展示专用
| Token | 字号 | 字重 | 用途 |
|---|---|---|---|
| `statValue` | 28sp | w700 | 统计卡片数值 |
| `statUnit` | 12sp | w400 | 统计卡片单位 |
| `statLabel` | 10sp | w400 | 统计卡片标签 |
| `metricValue` | 14sp | w600 | 指标数值 |
| `metricLabel` | 12sp | w400 | 指标标签 |

---

## 间距（Spacing）

| Token | 值 | 用途 |
|---|---|---|
| `xs` | 4dp | 图标与文字间距 |
| `sm` | 8dp | 列表项内部 |
| `md` | 16dp | 卡片内边距（标准） |
| `lg` | 24dp | 区块间距 |
| `xl` | 32dp | 页面边距 |
| `xxl` | 48dp | 区域分隔 |

---

## 圆角（Radius）

| Token | 值 | 用途 |
|---|---|---|
| `xs` | 4dp | 极小圆角 |
| `sm` | 6dp | 标签 |
| `md` | 8dp | 按钮/卡片（主要使用） |
| `lg` | 12dp | 弹窗/底部抽屉顶部 |
| `xl` | 16dp | 大弹窗 |
| `full` | 9999dp | 圆形（头像/FAB） |

---

## 阴影（Shadows）

| Token | 参数 | 用途 |
|---|---|---|
| `cardElevation0` | 无阴影，仅1px边框 | 扁平卡片 |
| `cardElevation1` | offset(0,1) blur3 black6% | 普通卡片 |
| `cardElevation2` | offset(0,2) blur6 black10% | 悬浮卡片 |
| `cardElevation3` | offset(0,4) blur12 black15% | 弹出层 |

---

## 核心组件规范

### 卡片（Card）
- 背景：`surface` (#FFFFFF)
- 边框：1dp `border` (#E0E0E0)
- 圆角：`md` (8dp)
- 内边距：`md` (16dp)
- 阴影：`cardElevation1`
- 点击反馈：scale 缩放到 0.98，100ms

### 统计卡片（StatCard）
- 布局：图标 + 数值（statValue 28sp bold）+ 单位（statUnit）+ 标签（statLabel）
- 最小宽度：100dp，推荐高度：80–100dp

### 操作栏（ActionBar，底部固定）
- 背景：`surface`，阴影：`cardElevation2`
- 主按钮：占主要宽度，次按钮：图标按钮
- 内边距：`md`，适配底部安全区

### 可展开区块（ExpandableSection）
- 展开/折叠动画：300ms easeInOut
- 图标旋转：90度

### 骨架屏（Skeleton）
- 颜色：`divider` → `background` 渐变动画
- 用于初次加载，模拟真实布局

---

## 信息架构三层结构

| 层级 | 用途 | 信息密度 |
|---|---|---|
| 概览层（Overview） | 首页仪表盘、模块入口 | 低，突出重点 |
| 列表层（List） | 路线列表、行程列表等 | 中，便于扫描比较 |
| 详情层（Detail） | 路线详情、行程详情等 | 高，支持深入了解 |
