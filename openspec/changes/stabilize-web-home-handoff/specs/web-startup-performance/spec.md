## ADDED Requirements

### Requirement: Mobile viewport is established before startup rendering
The Web entry document SHALL declare a device-width viewport before rendering the static startup presentation.

#### Scenario: Application opens on a mobile browser
- **WHEN** the HTML entry document is parsed before Flutter starts
- **THEN** the static startup presentation uses the device logical width and does not render at a desktop layout width before being rescaled
