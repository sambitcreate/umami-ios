# Apple Design Audit

## Experience goal

Umami Analytics should feel calm, direct, and trustworthy: live data should update without visual disruption, controls should respond immediately, and dense analytics should remain readable at every supported text size and window width.

## Audit summary

The app already uses a strong native foundation: semantic system colors, SF Symbols, standard navigation and controls, Dynamic Type text styles, VoiceOver labels, pull-to-refresh, destructive-action confirmation, and availability-gated Liquid Glass APIs.

The highest-value gaps were:

1. Interactive dashboard cards did not provide unified touch-down feedback.
2. Detail-tab changes snapped between large content regions without spatial continuity.
3. Loading overlays obscured context instead of communicating status as a lightweight layer.
4. The overview stat cards used a fixed two-column composition that became cramped at accessibility text sizes.
5. Card backgrounds and accessibility fallbacks varied between screens.

## Implemented plan

- Add shared card, press-feedback, and loading primitives using semantic colors and system materials.
- Respect Reduce Motion, Reduce Transparency, and Increased Contrast in those primitives.
- Add critically damped, interruptible detail-tab transitions with a reduced-motion cross-fade.
- Keep the selected detail tab visible in the horizontal tab strip.
- Make overview stat cards adapt to available width and switch to one column for accessibility text sizes.
- Preserve native navigation, scrolling, menus, and gestures rather than replacing familiar platform behavior.

## Recommended follow-up work

- Run Accessibility Inspector and VoiceOver task flows for login, website management, filters, and session detail.
- Add screenshot tests for light/dark mode, increased contrast, reduced transparency, and accessibility Dynamic Type.
- Consolidate repeated analytics list sections and inline-error cards onto the shared surface primitive.
- Test arbitrary iPad window widths and landscape layouts, especially charts and session detail.
- Add meaningful haptics only for committed actions such as starring a website or completing a save; avoid feedback on routine navigation.
