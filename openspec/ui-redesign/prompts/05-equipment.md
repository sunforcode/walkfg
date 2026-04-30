# Stitch Prompt — 装备主页（Equipment）

---

```
Design the Equipment (Gear) screen for the Walk hiking app (iOS, Cupertino style).

Navigation bar: "装备" title, right side: "+" icon button.

Content from top to bottom:

1. QUICK FILTER CHIPS (horizontal scroll)
   - 全部 | 进行中 | 已完成 | 已归档
   - Active: filled blue, white text; Inactive: white, gray border

2. SEARCH BAR
   - Rounded gray background, magnifier icon, placeholder "搜索装备清单..."

3. ACTION BUTTONS ROW (3 equal buttons, outlined style)
   - "＋ 新建清单" (blue outlined)
   - "📋 从模板创建" (gray outlined)
   - "🎒 装备库" (gray outlined)

4. EQUIPMENT LIST (vertical)
   Show 3 equipment list cards. Each card (white, bordered, 8px radius, 16px padding):
   - Left: colored backpack icon (blue/orange/green based on status)
   - Top row: list name "五台山装备清单" (bold) + status badge right-aligned
     - "准备中" = orange badge
     - "已完成" = green badge
   - Second row: route name "五台山经典线路" (gray, small)
   - Progress bar: blue fill, "12/18 件已打包 · 67%"
   - Bottom row: "8.2 kg" weight (left) + "修改于3天前" (right, gray small)

   Card 1: 五台山装备清单, 准备中, 12/18, 8.2kg
   Card 2: 秋季日间徒步, 已完成, 8/8, 3.1kg
   Card 3: 冬季登山备用, 已归档, 0/15, 0kg

5. FAB: blue circle "+" button, bottom right

Bottom tab bar: Home, Routes, center FAB, Gear (active blue), Profile.
```
