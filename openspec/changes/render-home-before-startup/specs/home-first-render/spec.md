## ADDED Requirements

### Requirement: Home shell renders before startup completion
The application SHALL render the home shell as the first Flutter UI without waiting for network, authentication, cache, route, weather, or map data initialization.

#### Scenario: Startup is still pending
- **WHEN** Flutter has produced its first frame but foundational startup work is incomplete
- **THEN** the user sees the home branding, primary route action, and navigation control instead of a generic loading screen

### Requirement: Home data waits for foundational readiness
The home page SHALL defer route, weather, and map data requests until the foundational startup future completes.

#### Scenario: Startup completes after home is visible
- **WHEN** the home shell is visible and foundational startup completes
- **THEN** the page begins loading selected-route data asynchronously and replaces only the relevant home content when data becomes available
