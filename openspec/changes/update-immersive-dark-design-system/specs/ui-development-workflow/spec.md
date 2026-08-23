## ADDED Requirements

### Requirement: UI 页面类型识别

Agent 或开发者在新增或修改 Flutter 页面前 MUST 将页面识别为 `immersive` 内容型页面或 `utility` 工具型页面，并依据 `design-system` Spec 选择页面骨架。

#### Scenario: 内容型页面

- **WHEN** 页面主要用于展示路线、目的地、行程、攻略或其他具有核心视觉内容的对象
- **THEN** Agent MUST 优先采用 `immersive` 页面模式
- **THEN** Agent MUST 评估全屏封面式大图是否适合作为首屏主体

#### Scenario: 工具型页面

- **WHEN** 页面主要用于编辑、设置、表单填写或高密度数据操作
- **THEN** Agent MUST 采用 `utility` 页面模式
- **THEN** Agent MUST NOT 为满足形式而添加与业务无关的大图

### Requirement: 公共组件优先工作流

Agent 在编写 UI 实现前 MUST 搜索现有 Design Token、页面骨架和公共组件，并按“直接复用、组合复用、受控扩展、业务局部实现”的顺序决策。

#### Scenario: 已有组件满足需求

- **WHEN** 公共组件已经覆盖所需语义和交互
- **THEN** Agent MUST 直接使用该组件
- **THEN** Agent MUST NOT 在业务页面复制其布局、样式或状态逻辑

#### Scenario: 已有组件缺少一个通用变体

- **WHEN** 至少两个真实业务场景需要同一种新视觉或交互变体
- **THEN** Agent MUST 优先为现有公共组件增加受控变体
- **THEN** 变体 MUST 具有语义名称，不得仅以任意颜色或尺寸参数表达

#### Scenario: 需求仅属于单一业务场景

- **WHEN** 视觉结构只服务于一个业务页面且没有稳定复用证据
- **THEN** Agent MAY 在业务目录创建局部组件
- **THEN** 局部组件仍 MUST 使用 Design Token 和公共视觉原语

### Requirement: UI 变更说明

每个 UI 变更提案和实现报告 MUST 说明页面模式、复用的公共组件、新增或扩展的组件，以及新增 Design Token 的必要性。

#### Scenario: 提交 UI 实现

- **WHEN** Agent 完成 UI 实现并报告变更
- **THEN** 报告 MUST 列出使用的页面模式和公共组件
- **THEN** 如新增公共组件或 Token，报告 MUST 说明现有能力为何不足

### Requirement: Test-First 视觉契约

新增或修改公共 UI 组件时 MUST 在实现前定义最窄的 Widget 测试或等价视觉契约，覆盖组件结构、受控变体和关键交互状态。

#### Scenario: 新增公共组件

- **WHEN** Agent 计划新增公共 UI 组件
- **THEN** Agent MUST 先添加能够失败的 Widget 测试或契约测试
- **THEN** 测试 MUST 至少覆盖默认变体和一个关键交互或降级状态

#### Scenario: 修改现有公共组件

- **WHEN** Agent 修改公共组件的视觉或行为
- **THEN** Agent MUST 更新对应测试以表达新的规范行为
- **THEN** Agent MUST 验证既有受支持变体未被意外破坏

### Requirement: 样式约束检查

UI 实现 MUST 使用 Design Token 和公共组件，禁止无说明地硬编码颜色、文字样式、圆角、阴影、模糊、动画时长和页面基础间距。

#### Scenario: 发现硬编码样式

- **WHEN** 审查发现业务页面直接声明可由现有 Token 表达的样式值
- **THEN** 该变更 MUST 被标记为不符合设计规范
- **THEN** Agent MUST 改用现有 Token，或先通过 Spec 说明新增 Token 的语义

#### Scenario: 发现重复基础组件

- **WHEN** 审查发现业务页面重新实现已有导航、网络图片、加载、错误、空态、Section Header 或操作组件
- **THEN** 该变更 MUST 被标记为不符合公共组件优先规则

### Requirement: UI 完成条件

Agent MUST 仅在规范、组件测试、静态分析和相关页面验证完成后声明 UI 任务完成。

#### Scenario: 完成 UI 任务

- **WHEN** Agent 准备声明 UI 任务完成
- **THEN** 相关 Widget 测试 MUST 通过
- **THEN** `flutter analyze` MUST 不新增诊断
- **THEN** Agent MUST 检查无图、加载失败、长标题、大字体和安全区等相关边界场景
- **THEN** 未执行的验证和剩余风险 MUST 明确报告
