## MODIFIED Requirements

### Requirement: Startup initialization respects dependency boundaries
The application SHALL render the home shell before nonessential initialization completes, SHALL run independent foundational initialization concurrently, and SHALL preserve ordering only where one step consumes another step's result.

#### Scenario: Independent startup work runs behind home
- **WHEN** the Flutter first frame has been produced
- **THEN** the home shell remains visible while environment loading, locale data initialization, and local storage initialization progress concurrently

#### Scenario: Authentication restoration keeps required ordering
- **WHEN** application configuration and foundational initialization have completed
- **THEN** the network client initializes before authentication state is restored

### Requirement: Flutter Web resources use safe cache policies
The web server SHALL prevent caching of the HTML document and release coordination files, SHALL allow the main application JavaScript to be stored and revalidated, and SHALL provide compression and bounded public caching for reusable renderer, font, image, and other static assets under `/app/`.

#### Scenario: Entry document is refreshed after release
- **WHEN** the browser requests `/app/index.html`
- **THEN** the response instructs the browser not to reuse a stale cached entry document

#### Scenario: Main application JavaScript is unchanged
- **WHEN** the browser revisits `/app/main.dart.js` with a matching validator
- **THEN** the server returns a validation response without retransmitting the complete JavaScript payload

#### Scenario: CanvasKit can be reused across visits
- **WHEN** the browser requests a CanvasKit JavaScript or WebAssembly resource under `/app/canvaskit/`
- **THEN** the response permits bounded public caching and supports compression for compressible content

## ADDED Requirements

### Requirement: Web bootstrap does not depend on unused third-party map assets
The Web entry document SHALL NOT synchronously load MapLibre scripts or styles unless the application actively uses the browser MapLibre global API.

#### Scenario: Application starts without MapLibre global API usage
- **WHEN** the browser loads the application entry document
- **THEN** Flutter bootstrap begins without waiting for resources from `unpkg.com`

### Requirement: HTML startup shell matches the home destination
The HTML shown before Flutter first frame SHALL present the essential visual structure and message of the simple home state rather than a generic loading indicator.

#### Scenario: Flutter engine is still downloading
- **WHEN** the Flutter engine has not produced its first frame
- **THEN** the user sees home branding and the primary route message without an indefinite loading spinner
