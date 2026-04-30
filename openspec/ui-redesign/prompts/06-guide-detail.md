# Stitch Prompt — 攻略详情页（Guide Detail）

---

```
Design the Guide Detail screen for the Walk hiking app (iOS, Cupertino style).

LAYOUT: Full-screen scrollable with collapsing cover header.

COVER HEADER (~280px height):
- Full-width cover photo (mountain trail scene)
- Dark gradient overlay from bottom (transparent to 60% black)
- Top-left: back arrow button (white, circular semi-transparent bg)
- Top-right: share icon button (white, circular semi-transparent bg)
- Bottom of image: guide title "五台山徒步完全攻略" (white, bold, 22sp)
- Below title: category tags "多日徒步" "中等难度" (white outlined chips, small)

SCROLLABLE CONTENT (white background):

1. OVERVIEW ROW
   - Stats: "2,341 阅读" · "156 点赞" · "89 收藏" (gray, small, separated by dots)

2. AUTHOR ROW (16px padding)
   - Circular avatar (40px)
   - Author name "山野行者" (bold, 15sp)
   - Publish date "2025年1月15日" (gray, 12sp)
   - Right: "关注" outlined blue button (small)

3. DIVIDER

4. ARTICLE BODY
   - Section heading "路线概述" (bold, 16sp)
   - Body text paragraph (14sp, line-height 1.6)
   - Section heading "装备建议"
   - Body text paragraph
   - Inline image (full width, 16px horizontal margin, 8px radius)

5. SECTION "推荐行程安排"
   - Day cards: Day 1 "台怀镇→南台 · 12.5km", Day 2, Day 3

6. SECTION "相关路线"
   - Horizontal scroll of 2 small route cards

BOTTOM ACTION BAR (fixed, white bg, top shadow):
- Heart icon button (toggleable, active=red) + "156"
- Bookmark icon button (toggleable, active=blue) + "89"
- Share icon button
- Comment icon button + "42"
```
