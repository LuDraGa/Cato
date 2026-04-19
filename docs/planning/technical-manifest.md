# Technical Architecture Manifest

**Status:** Planning
**Dependencies:** product-dna.md, data-model.md, complex-behaviors.md
**Feeds into:** project scaffold, CI/CD setup, all implementation

---

*Stack decisions, project structure, engine architecture, build pipeline, and testing strategy. The technical blueprint for how DailyTracker gets built and shipped.*

---

## Confirmed Stack

| Tool | Role | Cost |
|---|---|---|
| Flutter SDK | UI framework, cross-platform rendering | $0 |
| Riverpod | State management + DI (AsyncNotifier / StateNotifier) | $0 |
| Isar | Local NoSQL database, polymorphic data, full-text search | $0 |
| Shorebird | OTA code push without Play Store review | $0 (5k patches/mo) |
| Freezed | Immutable data classes, union types, codegen | $0 |
| Dio + Retrofit | Type-safe HTTP client, annotation-based API definitions | $0 |
| GoRouter | Declarative URL-based routing, deep link support | $0 |
| Firebase | Auth, Firestore, Cloud Functions (Phase 2) | $0 (Spark plan) |
| Sentry | Error tracking, performance monitoring | $0 (dev tier) |

---

## To Define

### Project Structure
- [ ] Flutter project scaffold (directory layout for lib/, test/, assets/)
- [ ] Engine module boundaries (input engine, viz engine, compatibility engine, notification engine)
- [ ] Provider architecture (which Riverpod providers, dependency graph)
- [ ] Config loading strategy (JSON assets → Isar on first run)

### Frontend & Design
- [ ] Navigation pattern (bottom tabs, screen map, deep linking)
- [ ] Component system (entry card, heatmap, score slider, completion ring — depth/elevation treatment)
- [ ] Material depth approach (neumorphic-adjacent? frosted glass? how to balance with Aesthetic Craft theme)
- [ ] Animation/motion library choices (Lottie? custom springs? flutter_animate?)
- [ ] Screen map and routing table

### Backend & Network
- [ ] Phase 1 network posture (local-only, Sentry + Shorebird outbound only)
- [ ] Phase 2 Firebase integration pattern (Firestore collections, security rules, Cloud Functions)
- [ ] Auth flow (Firebase Auth, token management, how it gates cloud features)
- [ ] Dio + Retrofit role vs direct Firebase SDK usage

### CI/CD & Infrastructure
- [ ] Local dev workflow (flutter run on device, wireless ADB, hot reload)
- [ ] Build pipeline (GitHub Actions: analyze, test, build, artifact upload)
- [ ] Shorebird integration (init, patch, release workflow)
- [ ] Signing & distribution (keystore, Firebase App Distribution for beta, Play Store for prod)
- [ ] Codegen workflow (build_runner for Freezed + Riverpod)

### QA & Testing
- [ ] Test pyramid (unit / widget / E2E split)
- [ ] Coverage targets per layer
- [ ] Testing tools (flutter_test, mocktail, golden_toolkit, patrol, integration_test)
- [ ] What to test first in v0.1
- [ ] Dev panel features (Isar browser, seed data, config viewer, clear data)
