# Stitch Prompt — 行程详情页（Trip Detail）

---

```
Design the Trip Detail screen for the Walk hiking app (iOS, Cupertino style).

Navigation bar: "行程规划" title, right side: pencil edit icon button.

Scrollable content from top to bottom:

1. MAP HEADER (~200px height)
   - Map showing the trip route with colored polyline
   - Subtle gradient overlay at bottom

2. TRIP OVERVIEW CARD (white, bordered, 8px radius)
   - Trip name "五台山3日行程" (bold, 20sp)
   - Date range "2025年3月15日 – 3月17日" with calendar icon
   - Status badge "规划中" (blue outlined chip)
   - Participants row: 3 circular avatars + "+2" overflow, "5人参与"

3. COLLAPSIBLE SECTIONS (each with title + chevron, tap to expand):

   "每日行程" (expanded by default):
   - Day 1 card: date "3月15日 周六", route "台怀镇→南台", distance "12.5 km", 2-3 activity items with time
   - Day 2 card, Day 3 card (collapsed style)

   "参与者":
   - List of 3 participants: avatar + name + role badge (组织者/参与者)

   "装备清单":
   - Summary: "五台山装备清单 · 18件 · 8.2 kg"
   - Progress bar: 12/18 packed

   "预算":
   - Total "¥1,200"
   - 4 category rows: 交通 ¥400, 餐食 ¥300, 住宿 ¥350, 其他 ¥150

   "天气 & 安全":
   - 3-day forecast: 3 mini cards (date, icon, temp range)
   - Safety alert chip if any

4. BOTTOM: "编辑行程" blue full-width button
```
