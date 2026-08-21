<!-- OPENSPEC:START -->
# OpenSpec Instructions

These instructions are for AI assistants working in this project.

Always open `@/openspec/AGENTS.md` when the request:
- Mentions planning or proposals (words like proposal, spec, change, plan)
- Introduces new capabilities, breaking changes, architecture shifts, or big performance/security work
- Sounds ambiguous and you need the authoritative spec before coding

Use `@/openspec/AGENTS.md` to learn:
- How to create and apply change proposals
- Spec format and conventions
- Project structure and guidelines

Keep this managed block so 'openspec update' can refresh the instructions.

<!-- OPENSPEC:END -->

# Walk Flutter AI Instructions

This file guides AI assistants working in the Flutter mobile app.

## Read Before Editing

1. `../AGENTS.md`
2. `../DEVELOPMENT_PARADIGM.md`
3. `../AI_DEVELOPMENT.md`
4. `walk/openspec/project.md`
5. Relevant specs under `walk/openspec/specs/`
6. Relevant files under `lib/model/`, `lib/service/`, `lib/core/network/`, and `lib/ui/`

If the change modifies API behavior, DTOs, enums, pagination, errors, route segment fallback, POI fallback, cache behavior, or cross-end behavior, create or update a root OpenSpec change first.

## Architecture Rules

Standard flow:

```text
Page/Widget -> State/Provider -> Service -> ApiClient -> walkbg API
```

- Pages and widgets must not call Dio directly.
- Services should use `ApiClient`, `ApiEndpoints`, typed model parsing, and explicit cache strategy.
- UI fallback can handle presentation states, but must not invent business facts.
- Mock data is only allowed in explicit development or test paths.
- JSON uses `snake_case`; Dart model fields use `camelCase` with `@JsonKey`.
- Keep complex UI split into focused widgets.

## Verification

Use:

```bash
flutter analyze
flutter test
```

For generated model changes, run build runner when required.
