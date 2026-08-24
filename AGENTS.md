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

## Flutter UI Workflow

Before adding or changing UI:

1. Read `openspec/specs/design-system/spec.md` and any active design-system change.
2. Classify the page as `immersive` or `utility`. Content pages use the full-bleed image direction; editing, settings, form, and dense-data pages use the utility dark direction.
3. Search `lib/ui/page/common/`, `lib/ui/widget/`, and `lib/theme/` before writing a component.
4. Decide in this order: direct reuse, composition, controlled variant, then business-local component. Extend a shared component only when at least two real screens need the same semantic variant; keep one-off structures local while composing shared tokens and primitives.
5. Add the narrowest failing Widget or contract test before changing a shared component.
6. Use semantic `AppColors`, `AppTypography`, `AppSpacing`, `AppRadius`, `AppShadows`, `AppBlur`, and `AppMotion` values. Do not hardcode reusable colors, text styles, radii, shadows, blur, motion durations, safe-area heights, or page gutters.
7. Keep a business-local composition local until the same structure is proven in at least two real screens. Do not build universal cards or scaffolds with arbitrary style parameters.

For review, search changed UI files for direct `Color(0x...)`, `TextStyle(`, `BorderRadius.circular(`, `BoxShadow(`, `ImageFilter.blur` or `BackdropFilter`, `Duration(`, reusable `EdgeInsets` page gutters, fixed safe-area padding, raw `Image.network`, and duplicate loading/error/empty implementations. A match is a review prompt, not an automatic failure: geometry and domain-specific drawing may remain local when documented.

Every UI proposal and completion report must state the page mode, reused components, extended or new components, and any new tokens with their justification. UI work is complete only after the relevant Widget tests pass, `flutter analyze` adds no diagnostics, `flutter test` passes, and applicable no-image, image-failure, long-title, large-text, small-screen, and safe-area states are checked. Report any skipped checks and remaining risk.

## Verification

Use:

```bash
flutter analyze
flutter test
```

For generated model changes, run build runner when required.
