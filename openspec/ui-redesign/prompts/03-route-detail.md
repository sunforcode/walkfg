# Stitch Prompt — 路线详情页（Route Detail）

---

```
Design the Route Detail screen for the Walk hiking app (iOS, Cupertino style).

LAYOUT: Full-screen map as background + floating top bar + bottom sheet drawer.

BACKGROUND: Full-screen trail map showing a colored route polyline (blue) over mountain terrain.

FLOATING TOP BAR (overlaid on map, semi-transparent dark background):
- Left: back arrow button (white icon, circular semi-transparent background)
- Center: route name "五台山经典线路" (white text, optional)
- Right: bookmark icon button + share icon button (both white, circular semi-transparent backgrounds)

BOTTOM SHEET (half-expanded, ~55% screen height, white, top corners 16px radius):
- Drag handle bar at top center (gray pill)
- Scrollable content inside:

  a) STATS ROW: 4 metric cards in a horizontal row
     - "38.5 km" 总距离
     - "↑2,400m" 总爬升
     - "3天" 行程天数
     - "★4.8" 评分
     Each: small label above, bold value below, light gray background, 8px radius

  b) SECTION "每日行程" (expandable, chevron right icon)
     - Day 1: "第1天 · 台怀镇→南台" · 12.5km
     - Day 2: "第2天 · 南台→中台" · 14.2km
     - Day 3: "第3天 · 中台→台怀镇" · 11.8km

  c) SECTION "水源点" (expandable) — water drop icon
  d) SECTION "营地" (expandable) — tent icon
  e) SECTION "补给点" (expandable) — store icon
  f) SECTION "季节装备建议" (expandable) — backpack icon
  g) PHOTO STRIP: horizontal scroll of route photos (~100px height)
  h) SECTION "相关路线": horizontal scroll of small route cards

BOTTOM ACTION BAR (fixed at bottom of sheet):
- "开始规划行程" full-width blue primary button, 50px height
```
