# **Bito Brand Color Palette & Visual Guidelines**
A cohesive, high-contrast, and kid-safe color system designed to work across high-tempo tablet game screens (dark mode for visual pop) and clean parent dashboard interfaces (light mode for readability and trust).

> **Implementation status:** The dark/kids palette below is implemented app-wide, including the Parent Zone and PIN screens (see `lib/core/theme/app_colors.dart`). The light "Clean Pearl" Parent Dashboard mode described in section 1 has **not** been built yet — parent-facing screens currently reuse the dark Cyber Slate theme rather than switching to light mode. Treat the light-mode rows below as a target for a future redesign, not current behavior.

## **1. Core Brand Colors**
These colors define the primary "Bito Studios" corporate identity and form the foundation of the app layouts, typography, and primary buttons.
| | | | | |
|-|-|-|-|-|
| **Usage** | **Color Name** | **Hex Code** | **Visual Sample** | **Best Used For** |
| **Primary Brand** | **Bito Cyan (Electric)** | #22D3EE | *Bright Cyan* | Active buttons, primary icons, and glow accents. |
| **Dark Base (Kids)** | **Cyber Slate** | #0F172A | *Slate 900* | Game backgrounds. Keeps screen glare low and neons bright. |
| **Light Base (Parents)** | **Clean Pearl** | #F8FAFC | *Slate 50* | Parent Dashboard background, cards, and text fields. *(not yet implemented — see status note above)* |
| **Text Primary (Dark)** | **Off-White** | #E2E8F0 | *Slate 200* | Main reading text in game mode. |
| **Text Primary (Light)** | **Deep Ink** | #0F172A | *Slate 900* | Main reading text in dashboard mode. *(not yet implemented)* |

## **2. The Character Color System**
Each character has a dedicated "glowing" palette. Using these colors consistently in menus, buttons, and backgrounds helps children navigate the app intuitively and strengthens their bond with the characters.

### Coco (The Puppy-Bot) — "Playful Trust"
- **Primary (Turquoise Glow):** #06B6D4 (Cyan 500)
- **Secondary (Teal Breeze):** #0EA5E9 (Sky 500)
- **Visual Tone:** Energetic, developmental, friendly, and accessible. Matches early-grade gameplay interfaces.

### Kato (The Boy-Bot) — "Velocity & Action"
- **Primary (Rocket Coral):** #F43F5E (Rose 500)
- **Secondary (Electric Orange):** #F97316 (Orange 500)
- **Visual Tone:** Highly dynamic, sporty, and competitive. Ideal for speed rounds and STEM challenges.

### Sona (The Girl-Bot) — "Cosmic Genius"
- **Primary (Cosmic Violet):** #A855F7 (Purple 500)
- **Secondary (Digital Indigo):** #6366F1 (Indigo 500)
- **Visual Tone:** Mystical, brainy, and highly creative. Used heavily in logic games, coordinates, and astronomical puzzles.

## **3. UI Functional Colors**
These are action colors reserved strictly for teaching moments, ensuring children receive clear, immediate feedback on their mathematical performance without confusing distractions.

- **Success Green (#10B981 - Emerald 500):** Used strictly when an answer is correct. Buttons flash this green, and Coco's pixel eyes turn to happy green carets.
- **Error/Alternative Red (#EF4444 - Red 500):** Used softly if an answer is wrong (to guide the child without demotivating them).
- **Timer Warning Orange (#F97316 - Orange 500):** The countdown fuse bar transitions from Cool Blue (#3B82F6) to this warning orange when under 5 seconds remain.

## **4. Visual Implementation Rules (Dos & Don'ts)**
- **DO** use deep, high-contrast dark backgrounds for the kids' math sprint. This prevents screen fatigue and keeps their eyes focused on the colorful central game buttons.
- **DO** keep the Parent Dashboard predominantly light and clean (#F8FAFC). It feels more administrative, trustworthy, and organized for adults. *(pending — current Parent Zone screens are dark-themed)*
- **DON'T** mix Kato's red/orange colors with Sona's purple/indigo on the same gameplay screen unless both characters are unlocked and playing together. This keeps the thematic brand distinct per character.
- **DON'T** use highly saturated primary colors (like pure #FF0000 red) that scream "danger." Kids are highly sensitive to criticism; soft neon transitions are far more supportive.
