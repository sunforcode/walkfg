# 装备模块（Equipment）

---

## 4.1 装备主页（EquipmentScreen）

**文件**：`lib/ui/page/equipment/equipment_screen.dart`

### 导航栏
- 标题"装备"
- 右侧"+"按钮（新建装备清单）

### 快速筛选栏
- 横向标签：全部 / 进行中 / 已完成 / 已归档
- "进行中"包含：计划中、准备中、准备就绪、使用中

### 搜索栏
- 搜索装备清单名称

### 操作入口行（3个按钮）
- "新建清单" → 跳转装备创建页
- "从模板创建" → 跳转模板选择页
- "装备库" → 跳转装备库页

### 装备清单列表
- 支持列表视图 / 网格视图切换（右上角切换按钮）
- 按筛选条件过滤

### 清单卡片内容
| 元素 | 说明 |
|---|---|
| 清单名称 | 加粗标题 |
| 关联路线 | 路线名称（次要文字） |
| 状态徽章 | 准备中（橙）/ 已完成（绿）/ 已归档（灰） |
| 打包进度 | 进度条 + "12/18 件已打包" |
| 总重量 | "8.2 kg" |
| 最后修改时间 | 次要文字 |

---

## 4.2 装备清单详情页（EquipmentDetailScreen）

**文件**：`lib/ui/page/equipment/equipment_detail_screen.dart`

### 导航栏
- 标题：清单名称
- 右侧：编辑按钮

### 顶部信息卡片
- 清单名称、关联路线、出行日期、状态
- 总重量统计（大字显示）
- 打包进度：已打包件数 / 总件数

### 装备分类列表（EquipmentCategoryList）
按分类展示，每个分类可展开/折叠：
- 帐篷 & 睡眠系统
- 服装
- 导航 & 通讯
- 食物 & 饮水
- 急救 & 安全
- 其他

### 装备项（EquipmentItemTile）
每行：
- 勾选框（是否已打包）
- 装备名称
- 品牌（次要文字）
- 重量（右侧）
- 点击展开详情（EquipmentItemDetailDialog）

---

## 4.3 装备创建页（EquipmentCreateScreen）

**文件**：`lib/ui/page/equipment/equipment_create_screen.dart`

- 填写清单名称
- 关联路线（可选，从路线列表选择）
- 出行日期范围
- 添加装备项（逐条添加）
- 保存后返回装备主页并刷新

---

## 4.4 装备模板页（EquipmentTemplateScreen）

**文件**：`lib/ui/page/equipment/equipment_template_screen.dart`

- 预设模板列表，按场景分类：
  - 夏季日间徒步
  - 多日山地徒步
  - 冬季登山
  - 溯溪 & 水上活动
- 每个模板：名称、适用场景描述、装备件数、参考总重量
- 选择模板 → 基于模板生成装备清单 → 返回装备主页

---

## 4.5 装备库页（EquipmentInventoryScreen）

**文件**：`lib/ui/page/equipment/equipment_inventory_screen.dart`

- 用户个人装备库（所有拥有的装备）
- 按分类浏览（同清单详情的分类体系）
- 每件装备：名称、品牌、重量、购买日期、状态（在用/闲置/损坏）
- 支持添加新装备、编辑、删除
