# 主框架 & 底部导航（MainLayout）

**文件**：`lib/theme/main_layout.dart`

---

## 布局结构

底部 Tab 导航栏，共 5 个 Tab：

| 位置 | Tab | 图标 | 对应页面 |
|---|---|---|---|
| 1 | 首页 | home | HomeScreen |
| 2 | 路线 | map | RouteDiscoveryScreen |
| 3 | **＋（FAB）** | — | 跳转 RouteSearchPage |
| 4 | 装备 | square_list | EquipmentScreen |
| 5 | 我的 | person | ProfileScreen |

---

## 核心交互

- 中间第 3 个 Tab 是**浮动圆形蓝色按钮（FAB）**，不切换 Tab，直接 push 到路线搜索页（新建行程入口）
- FAB 尺寸：60×60dp，圆形，颜色 `primary`，带蓝色光晕阴影
- 点击其他 Tab 正常切换页面，保持各 Tab 页面状态（`AutomaticKeepAlive`）
