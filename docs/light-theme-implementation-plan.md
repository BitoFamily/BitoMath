# Light Theme (Playground) — Implementation Plan

Goal: make theme a real Settings choice — **Classic** (existing dark Cyber Slate) vs **Playground** (new light Sunny Cream, see `docs/color-guidelines.md` §2) — applied app-wide, defaulting to Classic for new installs.

## Where things stand

This isn't starting from zero. A prior attempt at exactly this (issue #22) was built and works, but it landed on a local branch that was never merged to `origin/main`; a force-push from a teammate later made `main` diverge from it entirely. The work still exists as commits, currently kept alive on the local branch `recovered/theme-architecture` (tip `e2171ee`) so it survives normal git housekeeping — **that branch should be pushed to a remote or otherwise backed up before it's relied on**, since until now it only existed as unreachable reflog entries.

What that branch contains, oldest to newest:

| Commit | What it did |
|-|-|
| `c94eafb` | Core architecture: `AppColors` → instantiable `AppPalette` (dark + light variants), persisted `themeModeProvider`, app-wide `appPaletteProvider`, every screen/widget migrated off static `AppColors`/`AppTextStyles` to read from the active palette, Settings gets a Classic/Playground toggle. Test: `settings_theme_toggle_test.dart`. |
| `0ca6c01` | Continuous responsive type scale (`AppTypeScale`), composed with OS accessibility text size. |
| `a0c3a59` | Tactile `AppCard` treatment (solid border + offset shadow) and button press-sink. |
| `97f1bb0` | Wrong-answer wiggle (`WiggleAnimation`, shared with PIN entry) + restyled `AnswerButton` to match `AppCard`. |
| `e2171ee` | Faint background micro-textures on the game screen. |

**Important mismatch:** the light palette that shipped in `c94eafb` was "Playground Teal" — a teal *background* (`#6FDCCF → #5BCABD`). The palette now proposed in `docs/color-guidelines.md` (Playground Sunny Cream) uses a **cream background** with teal/gold as accents instead. The architecture is reusable as-is; the color *values* inside it are not — that swap is its own phase below (Phase 2).

## Phase 0 — Preserve the old work (done)

- [x] `recovered/theme-architecture` branch created at `e2171ee` so the commits aren't reflog-only.
- [ ] Push that branch to `origin` (or otherwise back it up) so it isn't solely dependent on this one local clone.

## Phase 1 — Recover & reconcile the architecture onto current `main`

A trial merge of `e2171ee` into `main` was run to scope the work and then aborted (no changes were kept). It produced **19 conflicting files**, several of them *add/add* conflicts — meaning both branches independently created or substantially rewrote the same file:

- `lib/app.dart`
- `lib/features/companions/screens/companion_select_screen.dart`
- `lib/features/game/screens/game_screen.dart`
- `lib/features/game/widgets/companion_reaction.dart` *(add/add)*
- `lib/features/game/widgets/timer_ring.dart`
- `lib/features/home/screens/home_screen.dart`
- `lib/features/home/widgets/age_band_sheet.dart`
- `lib/features/onboarding/screens/onboarding_screen.dart`
- `lib/features/progress/screens/progress_screen.dart`
- `lib/features/results/screens/results_screen.dart`
- `lib/features/rewards/screens/parent_zone_screen.dart`
- `lib/features/rewards/screens/pin_screen.dart`
- `lib/features/rewards/screens/rewards_screen.dart` *(add/add)*
- `lib/features/rewards/widgets/create_reward_sheet.dart`
- `lib/features/rewards/widgets/reward_progress_bar.dart`
- `lib/features/settings/screens/settings_screen.dart` *(add/add)*
- `lib/features/splash/screens/splash_screen.dart`
- `lib/l10n/app_en.arb` *(add/add)*
- `lib/shared/widgets/app_button.dart`
- `test/age_band_sheet_test.dart` *(add/add)*

Why so many: `main` gained real features since this branch forked — the rewards provider, companion reaction animations, CI pipeline, Android setup, sound settings — often in the *same* files the palette refactor touched. This is not a mechanical replay; each conflict needs a human read of both sides:

1. Merge (don't discard) `main`'s feature logic (rewards provider calls, companion reaction triggers, sound/localization additions) with the branch's palette-access changes (`AppColors.x` → `appPalette.x` via the provider).
2. For the add/add files, treat both versions as real: reconcile `main`'s newer feature (e.g. rewards screen behavior added after the fork) with the palette refactor's changes to the *same* screen, rather than picking one side wholesale.
3. After each file is resolved, `flutter analyze` before moving to the next — don't let errors compound across 19 files.
4. Run `flutter test`, paying particular attention to `settings_theme_toggle_test.dart` and any test file that was also add/add-conflicted (`age_band_sheet_test.dart`), since both branches may have written different assertions against the same widget.

Recommend doing this as its own focused session (or a dedicated worktree/branch), not mixed with palette or doc changes — it's a large, conflict-heavy merge and deserves undivided attention and its own review pass.

## Phase 2 — Swap in the Sunny Cream palette

Once `AppPalette` exists on `main` again (post Phase 1), replace the light-variant values from the old "Playground Teal" with the new palette from `docs/color-guidelines.md` §2:

| Token | Old (Playground Teal) | New (Playground Sunny Cream) |
|-|-|-|
| Background | `#6FDCCF → #5BCABD` | `#FFFBF2 → #FFF3DC` |
| Card fill | `#FFFFFF` | `#FFFFFF` *(unchanged)* |
| Card border | `#FFFDF9` | `#EDE0C8` |
| Text primary | `#2A3A40` | `#3A2E22` |
| Text secondary | `#5C6B70` | `#8A7A63` |
| Text muted | `#8B979B` | `#BFB093` |
| Primary accent | `#FFDB59` | `#0F766E` (Deep Teal) |
| Success | `#34B87A` | `#059669` |
| Error | `#FF8362` | `#FB7185` |
| Timer warning | `#FFA552` | `#F97316` |

Character colors (§3 of the guidelines) and the Classic/dark palette are untouched by this phase.

## Phase 3 — Wire up and verify the toggle

- Confirm `themeModeProvider` persists the choice (it did in the original implementation — verify the persistence mechanism still matches how `main` now handles other settings, e.g. `sound_settings_provider.dart`, since that pattern may have evolved since the fork).
- Confirm the app defaults to Classic on first launch (no persisted preference).
- Confirm the Settings screen toggle reads/writes through the reconciled provider, not a leftover static reference.

## Phase 4 — QA pass

- `flutter analyze` and `flutter test` clean.
- Manually exercise every screen in both themes (there are 22 files currently referencing colors directly — see the file list in `app_colors.dart` consumers) — specifically check text-on-accent contrast in Playground, since that's the mode most likely to introduce a low-contrast regression (Bito Cyan/Sunshine Yellow used somewhere they shouldn't be, per the Dos/Don'ts in the guidelines doc).
- Toggle theme mid-session (not just on cold start) and confirm no screen is left half-styled.

## Phase 5 — Optional follow-up polish (already built, lower priority)

The remaining commits on `recovered/theme-architecture` (`0ca6c01`, `a0c3a59`, `97f1bb0`, `e2171ee`) are visual polish layered on top of the architecture — responsive type scale, tactile card/button treatment, wrong-answer wiggle, background texture. None of them are palette-dependent, so they can be recovered independently, after Phases 1–4 are stable, using the same conflict-by-conflict approach as Phase 1.
