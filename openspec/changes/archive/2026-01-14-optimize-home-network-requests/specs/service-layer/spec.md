# service-layer Delta

## ADDED Requirements

### Requirement: 并行数据请求

业务层 SHALL 支持并行发起多个独立的 Service 请求以提升性能。

#### Scenario: 多个独立请求并行执行
- **GIVEN** Home 页面需要加载用户天气、行程、路线、攻略四种数据
- **WHEN** 使用 `Future.wait` 同时发起四个独立的 Service 请求
- **THEN** 所有请求并行执行
- **AND** 总加载时间等于最慢的单个请求时间
- **AND** 不等于所有请求时间之和

#### Scenario: 单个请求失败不影响其他请求
- **GIVEN** 并行发起多个请求
- **WHEN** 其中一个请求失败
- **THEN** 该请求返回默认值（空列表或空对象）
- **AND** 其他请求正常完成
- **AND** 错误信息被记录到日志

---

### Requirement: Service 层统一错误处理

Service 层方法 SHALL 捕获所有异常并返回合理的默认值，而非向上抛出异常。

#### Scenario: Service 方法内部错误处理
- **GIVEN** Service 方法调用失败（网络错误、解析错误等）
- **WHEN** 业务代码调用该 Service 方法
- **THEN** 方法返回合理的默认值（如空列表 `[]`）
- **AND** 不抛出异常到业务层
- **AND** 错误详情记录到日志中

#### Scenario: 业务代码无需处理 Service 异常
- **GIVEN** 业务代码调用 `TripService.getPlannedTrips()`
- **WHEN** Service 内部发生任何错误
- **THEN** 业务代码无需 try-catch
- **AND** 获得空列表或默认数据结构

---

### Requirement: 业务层数据源无感知

业务层代码 SHALL 对数据来源（Mock 或 API）保持无感知，仅调用 Service 方法获取数据。

#### Scenario: 业务代码统一调用方式
- **GIVEN** Service 层可能使用 Mock 数据或真实 API
- **WHEN** 业务代码需要获取数据
- **THEN** 仅调用 `ServiceName.method()` 即可
- **AND** 无需判断或处理数据来源
- **AND** 无需模拟网络延迟或处理 Mock 逻辑

#### Scenario: Service 层封装数据来源
- **GIVEN** TripService 内部使用本地 JSON Mock 数据
- **WHEN** 业务代码调用 `TripService.getPlannedTrips()`
- **THEN** Service 内部处理数据加载和延迟模拟
- **AND** 业务代码获得统一格式的返回数据
