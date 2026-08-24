## ADDED Requirements

### Requirement: Startup does not expose an unresolved business state
The application SHALL keep startup presentation separate from the home empty state and SHALL reveal a Flutter business page only after the initial home state resolves.

#### Scenario: A selected route is restored
- **WHEN** startup and initial route restoration are still in progress
- **THEN** the user sees only the neutral brand startup presentation and does not see `EmptyHome`
- **AND** when route data resolves, the application transitions directly to `RouteHome`

#### Scenario: No selected route exists
- **WHEN** startup completes and route restoration confirms that no route is selected
- **THEN** the application transitions once from the neutral startup presentation to `EmptyHome`

#### Scenario: Initial home loading fails
- **WHEN** startup or initial home data loading fails
- **THEN** the application removes the neutral startup presentation and displays the retryable error state

### Requirement: Startup presentation is business-neutral
The Web startup presentation SHALL NOT display controls or messages that imply whether a route exists.

#### Scenario: HTML is visible before Flutter resolves home state
- **WHEN** the browser is displaying the static startup layer
- **THEN** the layer displays only neutral brand visuals
- **AND** it does not display “找路线”, “还没有行程”, or an interactive menu

### Requirement: Initial route restoration loads once
The initial selected-route restoration SHALL produce at most one home data load for the restored route.

#### Scenario: Persisted route ID exists
- **WHEN** the selection service initializes from persisted storage with a non-empty route ID
- **THEN** the initial home flow loads that route once without a second listener-triggered request
