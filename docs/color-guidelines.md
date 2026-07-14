# **Bito Brand Color Palette & Visual Guidelines**
A cohesive, high-contrast, and kid-safe color system. Bito Math is moving to a **theme-as-a-setting** model: a parent picks **Classic** (dark) or **Playground** (light) for their child from Settings, and the choice applies everywhere — gameplay, Rewards, Progress, and the Parent Zone. There's no longer a fixed "dark for kids / light for parents" split.

> **Implementation status:** Only **Classic (Cyber Slate)** is built today, and it's used app-wide including the Parent Zone and PIN screens (see `lib/core/theme/app_colors.dart`). **Playground (Sunny Cream)**, defined below, is a **proposed palette — not yet implemented**. See `docs/light-theme-implementation-plan.md` for how it gets built and wired up as a real Settings toggle.

## **1. Classic — Cyber Slate (dark)**
The original theme. A deep, high-contrast background keeps screen glare low and neon accents bright — good for extended tablet play in varied lighting.

| Usage | Color Name | Hex |
|-|-|-|
| Background | Cyber Slate | `#0F172A` → `#1E293B` gradient |
| Card fill | Slate | `#1E293B` |
| Card border / divider | Slate Light | `#334155` |
| Text primary | Off-White | `#E2E8F0` |
| Text secondary | Slate 400 | `#94A3B8` |
| Text muted | Slate 500 | `#64748B` |
| Primary / active accent | Bito Cyan | `#22D3EE` |
| Secondary accent | Energy Yellow | `#FFD600` |

## **2. Playground — Sunny Cream (light)** *(proposed)*
A brighter, more toy-like counterpart to Classic — warm and inviting rather than stark white, with teal and yellow doing the work Bito Cyan and Energy Yellow do in the dark theme. Same structural roles as Classic; only the values change.

| Usage | Color Name | Hex |
|-|-|-|
| Background | Creamy Vanilla | `#FFFBF2` → `#FFF3DC` gradient |
| Card fill | Pure White | `#FFFFFF` |
| Card border / divider | Warm Sand | `#EDE0C8` |
| Text primary | Espresso Ink | `#3A2E22` |
| Text secondary | Warm Taupe | `#8A7A63` |
| Text muted | Soft Sand | `#BFB093` |
| Primary / active accent | Deep Teal | `#0F766E` |
| Primary accent (decorative/glow only, low-contrast for text) | Teal Breeze | `#2DD4BF` |
| Secondary accent (fills, badges, glows) | Sunshine Yellow | `#FFD600` |
| Secondary accent (text / icons — needs the extra contrast) | Honey Gold | `#CA8A04` |

**Why cream instead of white:** a pure-white background (`#FFFFFF`) reads clinical and competes visually with white card surfaces, so there's no way to "lift" a card off the page. Creamy Vanilla gives the background just enough warmth and separation that white cards pop, while still feeling light, clean, and friendly rather than a slate-dark inversion.

**Why Deep Teal, not Bito Cyan, as the light-mode primary:** Bito Cyan (`#22D3EE`) is tuned to glow against a near-black background; on a light background it loses contrast and reads washed-out. Deep Teal (`#0F766E`) keeps the same hue family — teal is still Bito's identity color — but is dark enough to work as button fills, active icons, and text-adjacent accents on a cream/white surface. Bito Cyan itself survives in Playground only as a *decorative* highlight (e.g. a glow behind an icon), never for text or thin strokes.

**Why two yellows:** Sunshine Yellow (`#FFD600`) is the same swatch used in Classic, kept for brand continuity in large fills and badges. But that yellow is too light to pass contrast as text or a small icon on a cream background, so Honey Gold (`#CA8A04`) — a deeper, more saturated gold — is the yellow used wherever it needs to read clearly at small sizes.

## **3. The Character Color System**
Each character has a dedicated "glowing" palette, and — unlike the rest of the app's chrome — **these colors are identical in both themes.** They're brand identity, not surface decoration, so Coco, Kato, and Sona always look like themselves regardless of which theme a child has picked.

### Coco (The Puppy-Bot) — "Playful Trust"
- **Primary (Turquoise Glow):** `#06B6D4` · **Secondary (Teal Breeze):** `#0EA5E9`
- Energetic, developmental, friendly. Matches early-grade gameplay interfaces.

### Kato (The Boy-Bot) — "Velocity & Action"
- **Primary (Rocket Coral):** `#F43F5E` · **Secondary (Electric Orange):** `#F97316`
- Highly dynamic, sporty, competitive. Speed rounds and STEM challenges.

### Sona (The Girl-Bot) — "Cosmic Genius"
- **Primary (Cosmic Violet):** `#A855F7` · **Secondary (Digital Indigo):** `#6366F1`
- Mystical, brainy, highly creative. Logic games, coordinates, astronomical puzzles.

**Don't** mix Kato's red/orange with Sona's purple/indigo on the same gameplay screen unless both characters are unlocked and playing together — this keeps each character's brand distinct.

## **4. UI Functional (Semantic) Colors**
Reserved strictly for teaching moments, so children get clear, immediate feedback without confusing distractions. The *role* of each is universal; the hex value is theme-specific, same as background/text/accent above.

| Role | Classic (dark) | Playground (light) | Notes |
|-|-|-|-|
| Success | Emerald `#10B981` | Meadow Green `#059669` | Flashes on a correct answer. |
| Error / wrong answer | Red `#EF4444` | Warm Coral `#FB7185` | Deliberately soft, never a harsh saturated red — see rule below. |
| Timer default | Cool Blue `#3B82F6` | Sky Blue `#0EA5E9` | The countdown ring's resting color. |
| Timer warning | Orange `#F97316` | Orange `#F97316` | Ring shifts to this under 5 seconds remaining — same hue works on both backgrounds. |

## **5. Visual Implementation Rules (Dos & Don'ts)**
- **DO** keep the *role* of a color identical across themes (e.g. "primary accent," "card border") and vary only the hex value — never hardcode a color outside the central palette definition (`app_colors.dart`).
- **DO** default new installs to Classic (dark). Playground is an opt-in setting, not a replacement.
- **DO**, in Playground, reserve Bito Cyan and Sunshine Yellow for decorative fills/glows/badges — use Deep Teal and Honey Gold wherever the color is carrying text or a small icon, so contrast holds up.
- **DON'T** use highly saturated, alarm-style colors (like pure `#FF0000` red) for wrong answers in either theme. Kids are sensitive to negative feedback; a softer red/coral is far more supportive than a color that reads as "danger."
- **DON'T** mix character brand colors across characters on the same gameplay screen (see §3).
