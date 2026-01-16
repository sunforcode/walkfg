# Change: 定义前后端 API 接口协议规范

## Why
当前前后端分离开发缺少统一的接口协议规范，导致：
1. 前端定义的 API 端点与后端实际实现不一致
2. 缺少数据模型映射规则（Dart camelCase ↔ Kotlin/JSON snake_case）
3. 没有明确的接口变更流程，前后端协作效率低
4. API 响应格式、错误处理、分页规范等未统一约定

## What Changes
- **新增** API 接口协议规范 (`api-contract`)，定义前后端必须遵循的接口契约
- 包含以下规范内容：
  - RESTful API 设计约定（URL 规范、HTTP 方法、状态码）
  - 统一响应格式（成功/错误响应结构）
  - 数据模型命名映射规则（前端 camelCase ↔ 后端 snake_case）
  - 枚举类型处理规范（整数值映射）
  - 分页、排序、过滤参数规范
  - 时间日期格式约定
  - 接口版本管理策略
  - 接口变更流程（设计 → 评审 → 实现 → 联调）
- 不修改现有代码，仅定义规范供后续开发遵循

## Impact
- **Affected specs**: 
  - 新增 `api-contract` - 前后端接口协议规范
  - 参考 `api-endpoints` - 前端 API 端点定义
  - 参考 `backend-architecture` - 后端架构规范
- **Affected code**: 
  - 后续前端 API 调用代码需遵循此规范
  - 后续后端 API 实现需遵循此规范
  - 当前代码不受影响（规范为指导性文档）
- **Cross-project impact**:
  - 需要在 walkbg 项目中同步此规范
  - 建议在两个项目的 `openspec/specs/` 中都保留副本
