# Stitch Prompt — 路线发现页（Route Discovery）

---

```
Design the Route Discovery screen for the Walk hiking app (iOS, Cupertino style).

Navigation bar: "路线" title, no action buttons.

Content from top to bottom:

1. MAP VIEW (~160px height, collapsible)
   - Shows a trail map with route markers
   - Bottom-right: expand/collapse toggle button with chevron icon
   - Subtle rounded corners at bottom

2. FILTER CHIPS (horizontal scroll, below map)
   - Options: 全部 | 热门 | 当季 | 简单 | 中等 | 困难
   - Active chip: filled blue background, white text
   - Inactive chip: white background, gray border, dark text

3. SECTION "热门路线" with subtitle "根据你的偏好推荐" and "查看全部 ›"
   - Horizontal scroll of route cards (~200px wide, ~260px tall)
   - Each card: full cover photo top, route name bold, location with pin icon, metrics row (distance icon "15.2 km", elevation icon "↑850m"), difficulty badge chip

4. SECTION "当季推荐" with subtitle "适合当前季节的路线" and "查看全部 ›"
   - Same horizontal card style

5. SECTION "全部路线" with "查看全部 ›"
   - Vertical list of route cards
   - Each card: left thumbnail (80×80, rounded), right side: route name bold, location gray, metrics row, difficulty badge
   - Show 4 cards then "查看更多路线" blue full-width button

Bottom tab bar: Home, Routes (active blue), center FAB, Gear, Profile.
```
