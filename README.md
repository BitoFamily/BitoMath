# BitoMath

**Learn, earn, reward.**

BitoMath is a gamified mathematics app for children in Grades 1–3 (ages 5–8). Kids earn stars by completing timed math sprints, and parents define what those stars are worth — screen time, outings, treats — turning in-app progress into real-world motivation.

This is the launch app of the [Bito](https://github.com/BitoFamily) educational universe, built around three characters: **Coco**, **Kato**, and **Sona**.

---

## What it does

- **Timed math sprints** — 60-second rounds across addition, subtraction, multiplication, and division, difficulty-scaled per grade band
- **Star economy** — every correct answer earns stars; streaks and accuracy are tracked across sessions
- **Real-world rewards** — parents set custom goals (e.g. "100 stars = trip to the cinema") behind a PIN-protected parent zone
- **Progress dashboard** — per-topic accuracy, session history, streaks, and tier progression (Bronze → Silver → Gold → Diamond)
- **Three companions** — Coco is playable at launch; Kato and Sona are teased and unlockable in future updates

---

## Tech stack

| Concern | Choice |
|---|---|
| Framework | Flutter 3.x (Dart) |
| State | Riverpod |
| Navigation | go_router |
| Persistence | shared_preferences (Phase 1) |
| Fonts | Google Fonts (Nunito) |
| Audio | audioplayers |
| Platforms | Android · iOS · Web |

---

## Project structure

```
lib/
├── core/
│   ├── constants/       # App-wide constants and character roster
│   ├── navigation/      # go_router route definitions
│   ├── persistence/     # Player profile model and Riverpod provider
│   ├── services/        # Sound service
│   └── theme/           # Brand colors, text styles, and app theme
├── features/
│   ├── companions/      # Character selection screen and companion data
│   ├── game/            # Game engine, question generator, timer, answer buttons
│   ├── home/            # Home screen and character carousel
│   ├── onboarding/      # First-run name and grade setup
│   ├── progress/        # Session history and accuracy charts
│   ├── results/         # Post-round summary screen
│   ├── rewards/         # Parent zone, PIN screen, reward creation and progress
│   └── splash/          # Animated splash screen
└── shared/
    └── widgets/         # AppButton, CharacterDisplay, StatBadge
```

---

## Getting started

**Prerequisites:** Flutter 3.3+ and Dart 3.3+

```bash
git clone https://github.com/BitoFamily/BitoMath.git
cd BitoMath
flutter pub get

# Run on a connected device or emulator
flutter run

# Run in Chrome
flutter run -d chrome

# Build web release
flutter build web
```

---

## Grade bands and topics

| Band | Ages | Topics unlocked |
|---|---|---|
| Grade 1 | 5–6 | Addition, Subtraction |
| Grade 2 | 6–7 | Addition, Subtraction, Multiplication |
| Grade 3 | 7–8 | Addition, Subtraction, Multiplication, Division |

Parents can further narrow focus to a single topic from the parent zone.

---

## Characters

| Character | Status | Brand color |
|---|---|---|
| Coco — The Puppy-Bot | Playable | Turquoise `#06B6D4` |
| Kato — The Boy-Bot | Coming soon | Rocket Coral `#F43F5E` |
| Sona — The Girl-Bot | Coming soon | Cosmic Violet `#A855F7` |

---

## Bito ecosystem

BitoMath is one app within the broader Bito platform under [BitoFamily](https://github.com/BitoFamily).

| Repo | Role |
|---|---|
| [BitoCore](https://github.com/BitoFamily/BitoCore) | Shared character assets, UI themes, and common game logic |
| [BitoBackend](https://github.com/BitoFamily/BitoBackend) | Cloud sync, authentication, cross-app data |
| [BitoLocalization](https://github.com/BitoFamily/BitoLocalization) | Translation pipeline — EN, FR, HI, AR |
| [BitoScience](https://github.com/BitoFamily/BitoScience) | Phase 2 subject expansion |
| [BitoParents](https://github.com/BitoFamily/BitoParents) | Dedicated parent companion portal |

---

## Roadmap

- [x] Core game loop with timed sprints
- [x] Star economy and real-world reward system
- [x] Parent zone with PIN protection
- [x] Progress tracking and session history
- [x] Coco companion (playable)
- [ ] Kato and Sona unlock paths
- [ ] Cloud save via BitoBackend
- [ ] Multilingual support via BitoLocalization
- [ ] BitoScience launch

---

## License

Private — © BitoFamily. All rights reserved.
