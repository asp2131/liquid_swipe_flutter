# Plan: Vertical Axis Swipe Support

## Task Description
Add vertical swiping support to the liquid_swipe_flutter package. Currently the package only supports horizontal (x-axis) drag gestures and clip/reveal logic. This plan changes the drag math and clip/reveal logic to support y-axis swiping, and exposes an `Axis.vertical` option so consumers can choose between horizontal and vertical liquid swipe.

## Objective
When complete, users can pass `swipeAxis: Axis.vertical` to `LiquidSwipe` and get a fully functional vertical liquid swipe where:
- Drag gestures are detected on the y-axis (up/down instead of left/right)
- The wave clip path reveals from top or bottom instead of left or right
- The slide icon is positioned on the horizontal axis instead of vertical
- All existing horizontal behavior remains the default and unchanged

## Problem Statement
The liquid swipe effect is hardcoded to horizontal (x-axis) gestures and right-edge wave reveals. There is no way to use the effect vertically (e.g., for story-like or card-stack UIs that swipe up/down). Every layer of the stack — gesture detection, direction enums, clip math, icon positioning, and animation — assumes horizontal-only operation.

## Solution Approach
Introduce an `Axis swipeAxis` parameter (default `Axis.horizontal`) threaded from `LiquidSwipe` through `LiquidProvider` → `PageDragger` → `PageReveal` → `WaveLayer`/`CircularWave`. At each layer, branch on the axis to swap the coordinate system:

1. **Directions**: Add `topToBottom` / `bottomToTop` to `SlideDirection` enum, or reinterpret existing directions contextually based on axis.
2. **Gesture detection**: Switch from `onHorizontalDrag*` to `onVerticalDrag*` when axis is vertical.
3. **Drag math**: Swap dx→dy for primary slide percent; swap the secondary reveal axis accordingly.
4. **Clip paths (WaveLayer & CircularWave)**: Rotate the wave 90° — the wave center moves along x instead of y, the side reveal becomes top/bottom, and bezier control points transpose.
5. **Icon positioning**: The slide icon sits at the bottom edge (not right edge) and moves along x instead of y.
6. **Animation**: `AnimatedPageDragger` already operates on abstract percent values — minimal changes needed, just ensure the correct target percent is used.

The cleanest approach: keep a single code path per component but parameterize axis-dependent values (primary/secondary offset, size dimension, alignment axis). This avoids duplicating the entire clip path logic.

## Relevant Files
Use these files to complete the task:

- `lib/Helpers/Helpers.dart` — Contains `SlideDirection` enum (needs new vertical values or axis-aware reinterpretation), constants, `WaveType` enum, `Utils` mixin
- `lib/Helpers/SlideUpdate.dart` — `SlideUpdate` model, no structural change needed but may carry axis info
- `lib/liquid_swipe.dart` — `LiquidSwipe` widget; add `swipeAxis` parameter, thread it to `LiquidProvider` and `PageDragger`
- `lib/Provider/LiquidProvider.dart` — `LiquidProvider`; store axis, adapt direction logic and page index math for vertical
- `lib/PageHelpers/page_dragger.dart` — `PageDragger`; switch gesture handlers and drag math based on axis
- `lib/PageHelpers/page_reveal.dart` — `PageReveal`; pass axis to clippers
- `lib/PageHelpers/animated_page_dragger.dart` — `AnimatedPageDragger`; ensure target percents respect axis
- `lib/Clippers/WaveLayer.dart` — `WaveLayer`; transpose the wave path for vertical axis
- `lib/Clippers/CircularWave.dart` — `CircularWave`; move center to bottom edge for vertical axis
- `lib/PageHelpers/LiquidController.dart` — `LiquidController`; no change expected unless exposing axis getter
- `example/lib/main.dart` — Add a vertical swipe example/toggle

### New Files
- None required. All changes are modifications to existing files.

## Implementation Phases

### Phase 1: Foundation — Enum & Parameter Threading
Add `swipeAxis` parameter to `LiquidSwipe`, thread `Axis` through `LiquidProvider`, and update `SlideDirection` enum to support vertical directions.

### Phase 2: Core Implementation — Gesture, Drag Math, Clip Paths
Switch gesture detectors, transpose drag math, and rotate WaveLayer/CircularWave clip paths for vertical mode.

### Phase 3: Integration & Polish — Icon, Animation, Example
Reposition the slide icon, verify animation math, update the example app with a vertical demo, and run tests.

## Team Orchestration

- You operate as the team lead and orchestrate the team to execute the plan.
- You're responsible for deploying the right team members with the right context to execute the plan.
- IMPORTANT: You NEVER operate directly on the codebase. You use `Task` and `Task*` tools to deploy team members to to the building, validating, testing, deploying, and other tasks.
  - This is critical. You're job is to act as a high level director of the team, not a builder.
  - You're role is to validate all work is going well and make sure the team is on track to complete the plan.
  - You'll orchestrate this by using the Task* Tools to manage coordination between the team members.
  - Communication is paramount. You'll use the Task* Tools to communicate with the team members and ensure they're on track to complete the plan.
- Take note of the session id of each team member. This is how you'll reference them.

### Team Members

- Builder
  - Name: builder-foundation
  - Role: Add `swipeAxis` parameter, update `SlideDirection` enum, thread axis through LiquidSwipe → LiquidProvider → PageDragger → PageReveal → Clippers
  - Agent Type: general-purpose
  - Resume: true

- Builder
  - Name: builder-vertical-gestures
  - Role: Implement vertical gesture detection and drag math in PageDragger, and vertical clip path logic in WaveLayer and CircularWave
  - Agent Type: general-purpose
  - Resume: true

- Builder
  - Name: builder-polish
  - Role: Reposition slide icon for vertical mode, verify animated_page_dragger, update example app with vertical demo
  - Agent Type: general-purpose
  - Resume: true

- Builder
  - Name: validator
  - Role: Run tests, verify both horizontal and vertical modes work, check for regressions
  - Agent Type: validator
  - Resume: false

## Step by Step Tasks

- IMPORTANT: Execute every step in order, top to bottom. Each task maps directly to a `TaskCreate` call.
- Before you start, run `TaskCreate` to create the initial task list that all team members can see and execute.

### 1. Update SlideDirection Enum & Add Axis Constants
- **Task ID**: update-slide-direction-enum
- **Depends On**: none
- **Assigned To**: builder-foundation
- **Agent Type**: general-purpose
- **Parallel**: false
- In `lib/Helpers/Helpers.dart`, add two new values to `SlideDirection`: `topToBottom` and `bottomToTop`
- Add a helper function or extension to determine if a `SlideDirection` is vertical: `bool isVertical(SlideDirection d) => d == SlideDirection.topToBottom || d == SlideDirection.bottomToTop;`
- Ensure existing horizontal values (`leftToRight`, `rightToLeft`, `none`) remain unchanged

### 2. Thread swipeAxis Parameter Through Widget Tree
- **Task ID**: thread-axis-parameter
- **Depends On**: update-slide-direction-enum
- **Assigned To**: builder-foundation
- **Agent Type**: general-purpose
- **Parallel**: false
- In `lib/liquid_swipe.dart`: Add `final Axis swipeAxis;` field with default `Axis.horizontal` to both constructors
- Pass `swipeAxis` to `LiquidProvider` constructor in the `ChangeNotifierProvider.create` callback
- In `lib/Provider/LiquidProvider.dart`: Add `final Axis swipeAxis;` field, accept in constructor, store it
- Pass `swipeAxis` to `PageDragger` in `_LiquidSwipe.build()`
- In `lib/PageHelpers/page_dragger.dart`: Add `final Axis swipeAxis;` field, accept in constructor
- Pass `swipeAxis` to `PageReveal` in `_PageDraggerState.build()`
- In `lib/PageHelpers/page_reveal.dart`: Add `final Axis swipeAxis;` field, pass to `WaveLayer` and `CircularWave`
- In `lib/Clippers/WaveLayer.dart`: Add `final Axis swipeAxis;` field
- In `lib/Clippers/CircularWave.dart`: Add `final Axis swipeAxis;` field

### 3. Implement Vertical Gesture Detection in PageDragger
- **Task ID**: vertical-gesture-detection
- **Depends On**: thread-axis-parameter
- **Assigned To**: builder-vertical-gestures
- **Agent Type**: general-purpose
- **Parallel**: false
- In `_PageDraggerState`, update `onDragUpdate` to branch on `widget.swipeAxis`:
  - **Horizontal (existing)**: `dx = dragStart.dx - newPosition.dx`, direction is `rightToLeft`/`leftToRight`, `slidePercentHor = (dx / fullTransitionPX).abs().clamp(0.0, 1.0)`, `slidePercentVer = (dy / height).clamp(0.0, 1.0)`
  - **Vertical (new)**: `dy = dragStart.dy - newPosition.dy`, direction is `bottomToTop` if dy > 0, `topToBottom` if dy < 0. `slidePercentHor = (dy / fullTransitionPX).abs().clamp(0.0, 1.0)` (this is the *primary* reveal percent, reusing the "hor" field as "primary"). `slidePercentVer = (newPosition.dx / width).clamp(0.0, 1.0)` (secondary axis, wave center X position).
- Switch `GestureDetector` from `onHorizontalDrag*` to `onVerticalDrag*` when `swipeAxis == Axis.vertical`
- Update icon `Alignment` for vertical mode: icon should be at the bottom edge, centered horizontally based on `slidePercentVer`

### 4. Update LiquidProvider for Vertical Directions
- **Task ID**: update-provider-vertical
- **Depends On**: thread-axis-parameter
- **Assigned To**: builder-vertical-gestures
- **Agent Type**: general-purpose
- **Parallel**: true (can run alongside task 3)
- In `LiquidProvider.updateData()`, update all direction checks to also handle `bottomToTop` (analogous to `rightToLeft` — going to next page) and `topToBottom` (analogous to `leftToRight` — going to previous page)
- Specifically in the `enableLoop` logic and non-loop logic, add equivalent conditions for vertical directions
- In `doneAnimating` block, set `slideDirection` to `SlideDirection.bottomToTop` when axis is vertical (instead of always `rightToLeft`)
- In the `_LiquidSwipe.build()` Stack, update the conditional that checks `slideDirection == SlideDirection.leftToRight` to also check `topToBottom` for the vertical case

### 5. Implement Vertical Clip Path in WaveLayer
- **Task ID**: vertical-wave-layer
- **Depends On**: thread-axis-parameter
- **Assigned To**: builder-vertical-gestures
- **Agent Type**: general-purpose
- **Parallel**: false
- In `WaveLayer.getClip()`, when `swipeAxis == Axis.vertical`, transpose the entire path:
  - The wave enters from the **bottom** edge instead of the **right** edge
  - `waveCenterY` → `waveCenterX = size.width * verReveal` (horizontal position of wave center)
  - `sideWidth` → `sideHeight` (bottom strip height instead of right strip width)
  - `waveHorRadius` → becomes vertical radius of the wave bulge
  - `waveVertRadius` → becomes horizontal radius of the wave bulge
  - The path: start at bottom-left, go right along bottom, up the right side, across the top, down the left side to meet the wave curve. The bezier curves mirror the horizontal ones but with x↔y transposed.
- Create a private method `_getVerticalClip(Size size)` to keep the code clean, called from `getClip` when axis is vertical
- `sidewidth`, `waveVertRadiusF`, `waveHorRadiusF`, `waveHorRadiusFBack` — create vertical equivalents that use `size.height` where the horizontal ones use `size.width` and vice versa
- For `slideDirection` checks, use `topToBottom`/`bottomToTop` instead of `leftToRight`/`rightToLeft`

### 6. Implement Vertical Clip Path in CircularWave
- **Task ID**: vertical-circular-wave
- **Depends On**: thread-axis-parameter
- **Assigned To**: builder-vertical-gestures
- **Agent Type**: general-purpose
- **Parallel**: true (can run alongside task 5)
- In `CircularWave.getClip()`, when `swipeAxis == Axis.vertical`:
  - Move center from right edge to bottom edge: `Offset(size.width * verReveal, size.height)` instead of `Offset(size.width, size.height * verReveal)`
  - Keep radius calculation the same (it's already axis-agnostic)
  - Update the path starting points to draw from bottom edge

### 7. Update AnimatedPageDragger for Vertical
- **Task ID**: update-animated-dragger
- **Depends On**: update-provider-vertical
- **Assigned To**: builder-polish
- **Agent Type**: general-purpose
- **Parallel**: false
- In `AnimatedPageDragger`, the transition goal `open` should set `endSlidePercentVer` to `positionSlideIcon` for horizontal, but for vertical it should be the horizontal center position (e.g., 0.5 or the icon's horizontal position)
- Ensure the `slideDirection` passed to `SlideUpdate` in the animation listener uses the correct vertical directions

### 8. Update Slide Icon Positioning for Vertical Mode
- **Task ID**: vertical-icon-position
- **Depends On**: vertical-gesture-detection
- **Assigned To**: builder-polish
- **Agent Type**: general-purpose
- **Parallel**: true (can run alongside task 7)
- In `_PageDraggerState.build()`, when `swipeAxis == Axis.vertical`:
  - The icon should be at the **bottom** center of the screen, not the right side
  - Alignment should be: `Alignment(-1.0 + Utils.handleIconAlignment(widget.iconPosition!) * 2, 1 - slidePercentHor)` — x uses iconPosition, y moves with drag
  - Opacity should fade based on `slidePercentHor` (primary reveal percent)
  - Visibility condition: hide when direction is `topToBottom` (going back)

### 9. Update LiquidSwipe Stack Order for Vertical
- **Task ID**: update-stack-order
- **Depends On**: update-provider-vertical, vertical-gesture-detection
- **Assigned To**: builder-polish
- **Agent Type**: general-purpose
- **Parallel**: false
- In `_LiquidSwipe.build()`, the Stack's first child conditionally shows active vs next page based on `slideDirection`. Add vertical direction checks:
  - `slideDirection == SlideDirection.leftToRight || slideDirection == SlideDirection.topToBottom` → show active page behind, next page in PageDragger
  - Otherwise → show next page behind, active page in PageDragger

### 10. Update Example App
- **Task ID**: update-example
- **Depends On**: update-stack-order
- **Assigned To**: builder-polish
- **Agent Type**: general-purpose
- **Parallel**: false
- In `example/lib/main.dart`, add a toggle or separate example that demonstrates `swipeAxis: Axis.vertical`
- Ensure horizontal mode still works as before

### 11. Run Tests & Validate
- **Task ID**: validate-all
- **Depends On**: update-example
- **Assigned To**: validator
- **Agent Type**: validator
- **Parallel**: false
- Run `flutter analyze` to check for static errors
- Run `flutter test` to execute existing tests
- Verify existing tests still pass (horizontal mode is default, no regression)
- Manually verify (or add test) that `SlideDirection` enum has all 4 values + none
- Check that `swipeAxis: Axis.horizontal` produces identical behavior to current version (no breaking change)
- Check that `swipeAxis: Axis.vertical` compiles and the clip paths produce valid paths

## Acceptance Criteria
- `LiquidSwipe(pages: pages, swipeAxis: Axis.vertical)` produces a vertical liquid swipe effect
- `LiquidSwipe(pages: pages)` (default) behaves identically to the current version — no regressions
- Both `WaveType.liquidReveal` and `WaveType.circularReveal` work in vertical mode
- The slide icon appears at the bottom edge in vertical mode and at the right edge in horizontal mode
- Loop and non-loop modes work correctly in both axes
- `LiquidController.animateToPage()` and `jumpToPage()` work in both axes
- `enableSideReveal` shows a top/bottom strip in vertical mode (analogous to right strip in horizontal)
- `preferDragFromRevealedArea` works with vertical gestures
- All existing tests pass
- `flutter analyze` reports no errors

## Validation Commands
Execute these commands to validate the task is complete:

- `cd /Users/akinpound/Documents/experiments/liquid_swipe_flutter && flutter analyze` - Static analysis, no errors expected
- `cd /Users/akinpound/Documents/experiments/liquid_swipe_flutter && flutter test` - All existing tests pass
- `cd /Users/akinpound/Documents/experiments/liquid_swipe_flutter && flutter build apk --debug 2>&1 | tail -5` - Verify it compiles (example app)
- `grep -r "swipeAxis" lib/` - Verify the parameter is threaded through all relevant files
- `grep -r "bottomToTop\|topToBottom" lib/` - Verify vertical directions exist in the codebase

## Notes
- The `slidePercentHor` and `slidePercentVer` field names are misleading in vertical mode (hor becomes the primary/reveal percent). Consider renaming to `slidePrimary`/`slideSecondary` in a future refactor, but for this task keep the existing names to minimize blast radius and breaking changes to the public `SlidePercentCallback` API.
- The WaveLayer bezier math is the most complex part. The transposition approach (swapping x↔y in all control points) should produce a visually correct 90° rotation of the wave. If the wave looks wrong, the control points may need manual tuning.
- No new dependencies are needed.
- `positionSlideIcon` in vertical mode represents the horizontal position of the slide icon (left-right) rather than vertical.
