# 攻略模块（Guide）

---

## 5.1 攻略详情页（GuideDetailScreen）

**文件**：`lib/ui/page/guide/guide_detail_screen.dart`

### 导航栏
- 默认透明（覆盖在封面图上）
- 随滚动渐变为不透明白色，同时显示攻略标题
- 左侧：返回按钮
- 右侧：分享按钮

### 封面区（GuideCoverWidget）
- 大图封面（全宽，约 280dp 高）
- 底部渐变遮罩（黑色透明渐变）
- 封面上显示：攻略标题（白色加粗）、分类标签（如"多日徒步"、"中等难度"）

### 内容区（滚动）

| 区块 | 组件 | 内容 |
|---|---|---|
| 概览 | GuideOverviewWidget | 标题、标签列表、阅读量、点赞数、收藏数 |
| 作者 | GuideAuthorWidget | 圆形头像、昵称、简介、关注按钮 |
| 正文 | GuideContentWidget | Markdown 渲染的攻略正文，含图片 |
| 行程建议 | GuideTripPlanWidget | 推荐行程安排（按天） |
| 相关路线 | GuideRelatedWidget | 横向滚动的相关路线卡片 |

### 底部操作栏（GuideActionBarWidget，固定）
- 点赞按钮（心形图标，可切换，激活时红色）
- 收藏按钮（书签图标，可切换，激活时蓝色）
- 分享按钮
- 评论按钮（带评论数）

### 状态
- 加载中：全页 loading
- 加载失败：错误页 + 重试
- 滚动超过封面高度时：导航栏标题渐显
