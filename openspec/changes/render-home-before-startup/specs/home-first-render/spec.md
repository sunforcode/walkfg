## ADDED Requirements

### Requirement: Home shell renders before startup completion
The application SHALL render the home shell as the first Flutter UI without waiting for network, authentication, cache, route, weather, or map data initialization.

#### Scenario: Startup is still pending
- **WHEN** Flutter has produced its first frame but foundational startup work is incomplete
- **THEN** the user sees the home branding, primary route action, and navigation control instead of a generic loading screen

### Requirement: Static shell remains until the final home state is known
The Web static home shell SHALL remain visible until startup and the initial home-data request resolve, then fade out once to reveal the final empty, route, or error state.

#### Scenario: A selected route is being restored
- **WHEN** Flutter has rendered but the selected route is still loading
- **THEN** the static shell remains visible and the user does not see an intermediate empty home before the route home

### Requirement: Home data waits for foundational readiness
The home page SHALL defer route, weather, and map data requests until the foundational startup future completes.

#### Scenario: Startup completes after home is visible
- **WHEN** the home shell is visible and foundational startup completes
- **THEN** the page begins loading selected-route data asynchronously and reveals the resolved home state when data becomes available

### Requirement: Home typography uses valid font resources
The application SHALL NOT register invalid or non-font files as its text font family and SHALL use a reliable platform sans-serif fallback when no bundled CJK font is available.

#### Scenario: Chinese home text is rendered
- **WHEN** the Web home displays Chinese labels
- **THEN** the browser renders them through a valid platform fallback without attempting to decode HTML files as fonts
