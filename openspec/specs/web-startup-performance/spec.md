# web-startup-performance Specification

## Purpose
定义 Flutter Web 启动阶段的渲染资源交付、初始化依赖顺序、Mock 预加载边界与缓存策略，确保应用在受限网络和版本发布后仍能可靠产生首帧。

## Requirements
### Requirement: Flutter Web uses self-hosted rendering resources
The Flutter Web release build SHALL include the renderer resources required to start the application and SHALL load them from the application origin rather than a third-party CDN.

#### Scenario: CanvasKit starts without third-party access
- **WHEN** a user opens the Flutter Web application in an environment that cannot access Google CDN
- **THEN** the browser loads CanvasKit from the `/app/canvaskit/` deployment path and produces the Flutter first frame

### Requirement: Startup initialization respects dependency boundaries
The application SHALL render a Flutter-owned startup state before nonessential initialization completes, SHALL run independent foundational initialization concurrently, and SHALL preserve ordering only where one step consumes another step's result.

#### Scenario: Independent startup work runs together
- **WHEN** the Flutter first frame has been produced
- **THEN** environment loading, locale data initialization, and local storage initialization may progress concurrently

#### Scenario: Authentication restoration keeps required ordering
- **WHEN** application configuration and foundational initialization have completed
- **THEN** the network client initializes before authentication state is restored

### Requirement: Production startup excludes Mock preload work
The application SHALL NOT preload Mock JSON assets when real services are enabled.

#### Scenario: Real service mode starts without Mock assets
- **WHEN** `useMockServices` is false during startup
- **THEN** the application proceeds without reading files under `assets/mock_data/`

### Requirement: Flutter Web resources use safe cache policies
The web server SHALL prevent caching of Flutter entry files that coordinate a release and SHALL provide compression and bounded public caching for reusable renderer, font, image, and other static assets under `/app/`.

#### Scenario: Entry document is refreshed after release
- **WHEN** the browser requests `/app/index.html`
- **THEN** the response instructs the browser not to reuse a stale cached entry document

#### Scenario: CanvasKit can be reused across visits
- **WHEN** the browser requests a CanvasKit JavaScript or WebAssembly resource under `/app/canvaskit/`
- **THEN** the response permits bounded public caching and supports compression for compressible content

