# 进度追踪

> 状态说明：⬜ 未开始 / 🔄 进行中 / ✅ 已完成

---

## 阶段一：Stitch 出图

| # | 页面 | Prompt 文件 | Stitch 生成 | 截图确认 | 备注 |
|---|---|---|---|---|---|
| 0 | 总体风格 | `prompts/00-global-style.md` | ⬜ | ⬜ | 第一步，必须先做 |
| 1 | 首页 | `prompts/01-home.md` | ⬜ | ⬜ | |
| 2 | 路线发现页 | `prompts/02-route-discovery.md` | ⬜ | ⬜ | |
| 3 | 路线详情页 | `prompts/03-route-detail.md` | ⬜ | ⬜ | 地图全屏+抽屉布局 |
| 4 | 行程详情页 | `prompts/04-trip-detail.md` | ⬜ | ⬜ | |
| 5 | 装备主页 | `prompts/05-equipment.md` | ⬜ | ⬜ | |
| 6 | 攻略详情页 | `prompts/06-guide-detail.md` | ⬜ | ⬜ | |
| 7 | 个人中心 | `prompts/07-profile.md` | ⬜ | ⬜ | |

**待补充 Prompt 的页面**（设计稿确认后再写）：
- 行程编辑页
- 装备清单详情页
- 路线搜索页
- 登录/注册页

---

## 阶段二：Flutter 落地

| # | 页面 | 功能文档 | 代码文件 | 落地状态 | 备注 |
|---|---|---|---|---|---|
| 0 | 主框架/导航栏 | `pages/00-navigation.md` | `lib/theme/main_layout.dart` | ⬜ | |
| 1 | 首页 | `pages/01-home.md` | `lib/ui/page/home/home_screen.dart` | ⬜ | |
| 2 | 路线发现页 | `pages/02-route.md` | `lib/ui/page/route/route_discovery_screen.dart` | ⬜ | |
| 3 | 路线详情页 | `pages/02-route.md` | `lib/ui/page/route/detail/route_detail_screen.dart` | ⬜ | |
| 4 | 行程详情页 | `pages/03-trip.md` | `lib/ui/page/trip/trip_detail_screen.dart` | ⬜ | |
| 5 | 行程编辑页 | `pages/03-trip.md` | `lib/ui/page/trip/trip_edit_screen.dart` | ⬜ | |
| 6 | 我的行程规划 | `pages/03-trip.md` | `lib/ui/page/trip/my_trip_plans_screen.dart` | ⬜ | |
| 7 | 装备主页 | `pages/04-equipment.md` | `lib/ui/page/equipment/equipment_screen.dart` | ⬜ | |
| 8 | 装备清单详情 | `pages/04-equipment.md` | `lib/ui/page/equipment/equipment_detail_screen.dart` | ⬜ | |
| 9 | 攻略详情页 | `pages/05-guide.md` | `lib/ui/page/guide/guide_detail_screen.dart` | ⬜ | |
| 10 | 个人中心 | `pages/06-profile.md` | `lib/ui/page/profile/profile_screen.dart` | ⬜ | |
| 11 | 登录/注册 | `pages/07-auth.md` | `lib/ui/page/profile/login_screen.dart` | ⬜ | |

---

## 设计决策记录

> 在此记录设计过程中的重要决策，方便后续查阅。

| 日期 | 决策 | 原因 |
|---|---|---|
| 2026-03-23 | 保留天空蓝+运动风格，做精细化提升 | 现有设计系统已较完善，不需要推倒重来 |
| 2026-03-23 | 先出设计稿再落地代码 | 避免反复修改代码，效率更高 |

---

## Prompt 迭代记录

> 记录每个页面 Prompt 的调整历史。

| 页面 | 版本 | 调整内容 |
|---|---|---|
| — | — | — |
