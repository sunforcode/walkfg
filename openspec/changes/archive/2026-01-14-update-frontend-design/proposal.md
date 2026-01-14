# Change: 前端设计系统升级 - 工具型应用渐进式信息架构

## Why

当前应用设计系统已建立基础的 Design Token，但缺乏统一的信息架构规范和现代化交互模式定义。需要升级设计系统，明确"概览→详情"的多层次信息展示策略，确保应用具备工具型产品的高效专业特点，同时符合现代 APP 的使用习惯。

## What Changes

### 1. 信息架构规范 (新增)
- 定义三层信息架构：概览层、列表层、详情层
- 规范每层的信息密度和展示策略
- 建立"渐进式展开"的交互模式

### 2. 页面布局模式 (新增)
- 首页仪表盘布局规范
- 列表页布局规范
- 详情页布局规范（Header + Tab/Segment 切换）
- 底部抽屉详情面板规范

### 3. 组件规范扩展 (新增)
- 统计卡片组件规范
- 数据卡片组件规范（含迷你图表）
- 列表项组件规范
- 可展开/折叠区块规范
- 操作栏组件规范

### 4. 交互模式规范 (新增)
- 加载状态（Skeleton）
- 刷新模式（下拉刷新、上拉加载）
- 过渡动效规范
- 手势交互规范

### 5. 现有 Design Token 优化 (修改)
- 补充数据展示相关的字体样式
- 补充卡片层级相关的阴影定义
- 补充交互状态相关的颜色定义

## Impact

- **Affected specs**: `design-system`
- **Affected code**: 
  - `lib/theme/` - 主题和 Token 定义
  - `lib/ui/page/` - 页面组件
  - `lib/ui/widget/` - 通用组件
- **Breaking changes**: 无，为扩展性升级

## References

- 设计参考：Apple Health、Strava、AllTrails
- 现有规范：`specs/design-system/spec.md`
