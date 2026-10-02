---
name: Darts Score (Дарцны оноо)
description: Dark, mint-lit x01 darts scorekeeper for phones on a pub table.
colors:
  background: "#080F0C"
  surface: "#0D1F17"
  lighter: "#112318"
  elevated: "#1A3628"
  primary: "#00E896"
  primary-deep: "#00C278"
  primary-shade: "#00B87A"
  gold: "#F5A623"
  orange: "#FF6B35"
  danger: "#F44336"
  text-primary: "#ECFDF7"
  text-secondary: "#7AA896"
  border: "#1D3D2D"
  border-subtle: "#152B20"
typography:
  display:
    fontFamily: "Manrope"
    fontSize: "26px"
    fontWeight: 900
  title:
    fontFamily: "Manrope"
    fontSize: "17px"
    fontWeight: 800
  body:
    fontFamily: "Manrope"
    fontSize: "15px"
    fontWeight: 700
    letterSpacing: "0.75px"
  label:
    fontFamily: "Manrope"
    fontSize: "13px"
    fontWeight: 700
  caption:
    fontFamily: "Manrope"
    fontSize: "11px"
    fontWeight: 400
rounded:
  key: "8px"
  control: "10px"
  card: "14px"
  panel: "16px"
  pill: "20px"
spacing:
  xs: "4px"
  sm: "8px"
  md: "12px"
  lg: "16px"
  xl: "20px"
components:
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.background}"
    rounded: "{rounded.card}"
    height: "52px"
  button-secondary:
    backgroundColor: "{colors.lighter}"
    textColor: "{colors.text-primary}"
    rounded: "{rounded.control}"
    height: "48px"
  card:
    backgroundColor: "{colors.lighter}"
    rounded: "{rounded.panel}"
    padding: "14px"
  scorecard-active:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.background}"
    rounded: "{rounded.card}"
  number-key:
    backgroundColor: "{colors.lighter}"
    textColor: "{colors.text-primary}"
    rounded: "{rounded.key}"
---

# Darts Score design system

## Overview

A scoreboard you glance at between throws, often in a dim bar, with the phone lying on a table or propped against the oche. It uses one dark scheme on purpose: a near-black green background, and a single neon-mint accent that marks whose turn it is and what to press next. Everything else stays quiet so the remaining scores read from arm's length.

The UI copy is in Mongolian. Darts jargon that players already use as-is stays in English: Single / Double / Triple, BUST, PPR, Bull.

## Colors

Tokens live in `lib/utils/colors.dart` (`BColors()`). Never write raw hex or `Colors.red` in a screen.

### Primary
- **primary `#00E896`**: whose turn it is, the primary action, and confirmed or positive state. Primary buttons and the active scorecard use `primaryGradient` / `primaryGradientDiagonal`, which fade into `primaryDeep` / `primaryShade`. Those two colors are only ever gradient end stops.
- **onPrimary**: text and icons on a mint fill. It is the background color.

### Secondary
- **gold**: the Double ring and Bull 25. It also marks the win moment (the trophy).
- **orange**: the Triple ring, Bull 50, and "next player".

### Neutral
- `background` → `surface` → `lighter` → `elevated` is the order surfaces stack in. Cards and keys sit on `lighter`.
- `textSecondary` is 6.2:1 on `lighter`. Use it for labels and metadata, never for scores.

### Named rules
- **One accent per meaning.** Mint = current or primary, gold = double, orange = triple, `danger` = bust, loss, delete or undo. Never use a ring color decoratively.
- **Danger is for consequences.** Busts, losses, destructive confirms and the undo key, nothing else.

## Typography

Manrope throughout, via the `BText` / `BComment` widgets with `TextSize` steps in `lib/utils/text_styles.dart`.

### Hierarchy
- **Score (`x3l`/`x2l`, w900):** remaining points. The largest thing on screen.
- **Title (`l`, w800):** screen titles and dialog headings.
- **Body (`m` 15pt, w700):** names, list rows, button labels.
- **Label (`s` 13pt / `xs` 12pt):** section headers (uppercase, 1.5 tracking) and metadata.
- **Caption (`x2s` 11pt):** PPR and the "+points" badges. **11pt is the floor;** nothing renders smaller.

Text follows the OS text-size setting. Fixed-height containers (scorecards, keys) wrap their text in `FittedBox(fit: BoxFit.scaleDown)` so large text shrinks to fit instead of clipping.

## Layout

- Portrait phone first. On tablets, content is centered with a max width of 560–600pt rather than stretched to the full screen.
- The game screen also supports landscape: a score strip on top, and the S/D/T key grids side by side, all sized from the available space with Expanded rows rather than hard-coded pixel sizes.
- On narrow phones (<360pt) the number pad drops from 7 columns to 5 so keys stay at least 44pt.
- Side padding is 16–20pt. Related items are 8pt apart, sections 20pt apart.

## Elevation & Depth

Depth comes from the surface steps plus colored glow, not grey drop shadows. Only primary or active elements glow (mint at about 30% alpha, 12–20 blur, 2–4pt y-offset). Stat cards may carry a faint mint halo. Never stack two glowing elements next to each other.

## Shapes

Rounded rectangles only: keys 8, controls 10, cards 14, panels 16, chips/pills 20. Avatars and icon badges are circles. Landscape game keys are square-edged so the grid reads as one surface.

## Components

All in `lib/utils/interaction.dart` unless noted.

### Pressable
Every tappable surface is built on it. It provides the button role, an accessible name (`semanticLabel`, which icon-only controls must set), a 0.96 scale and 80% opacity pressed state, and a minimum 44pt target. Don't wrap a raw `GestureDetector` around a `Container` for a button.

### Buttons
- **PrimaryButton:** a mint gradient that glows, for one per screen. With `onTap: null` it renders the disabled state (flat `lighter`).
- **SecondaryButton:** a `lighter` fill with a border. Pass `color: danger` for destructive actions.
- **IconTile / IconAction:** icon-only. `label` is required.

### Dialogs
`showConfirmDialog` (`lib/utils/dialogs.dart`) is the only confirmation dialog. Name the action in both the title and the button ("Тоглолтыг устгах уу?" / "Устгах"); never "OK" or "Yes". Prefer undo over confirming when recovery is safe.

### Feedback
`showSnackMsg` (`lib/utils/snackbar.dart`) handles transient top toasts (info / success / error) on `elevated`.

### Scorecard (signature)
Shows the remaining points. The active player is filled with the mint gradient; on a bust the card flashes danger-red with "BUST!" for 650ms. Its screen-reader label reads the name, the points left, and whose turn it is.

## Do's and Don'ts

### Do:
- Use `BColors()` tokens and the gradient getters.
- Build controls on `Pressable`, and label every icon-only control.
- Check `context.reduceMotion` before adding entrance animations or confetti.
- Keep game rules in `X01Engine` (`lib/core/game/x01_engine.dart`), with tests, never in a widget.

### Don't:
- Use text below 11pt, or fixed heights that clip text when the system font size is large.
- Add a second accent hue, gradient text, or grey drop shadows.
- Mix icon sets: HugeIcons stroke-rounded only.
- Add swipe gestures across the whole screen, because they fight the iOS edge-swipe back gesture.
