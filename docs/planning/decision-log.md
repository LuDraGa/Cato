# Decision Log

**Status:** Active (ongoing)

---

*Records key decisions with rationale. Prevents re-litigating the same questions from a different phase of development. Each entry captures what was decided, why, and what alternatives were rejected.*

---

## Template

```
### [DECISION_ID] — [Short Title]

**Date:** YYYY-MM-DD
**Status:** Decided | Revisiting | Reversed
**Context:** What prompted this decision?
**Decision:** What was decided?
**Alternatives considered:** What else was on the table?
**Rationale:** Why this over the alternatives?
**Consequences:** What does this commit us to or close off?
```

---

## Decisions

### D001 — Local-first with Isar over SQLite

**Date:** 2026-04-16
**Status:** Decided
**Context:** Need a local database for offline-first personal metrics with polymorphic data (scores, durations, text, media paths, booleans in same collection).
**Decision:** Isar.
**Alternatives considered:** SQLite (sqflite), Hive, Realm.
**Rationale:** Native Flutter/Dart. Embedded objects handle polymorphic MetricValue without JOIN gymnastics or EAV patterns. Auto schema migration on field additions. Built-in full-text search for journal entries. Web support via IndexedDB.
**Consequences:** Less ecosystem tooling for direct DB inspection (mitigated by dev panel). Isar is less battle-tested than SQLite at scale — acceptable for personal app.

### D002 — Riverpod over Bloc for state management

**Date:** 2026-04-16
**Status:** Decided
**Context:** Dynamic form builder needs per-tracker state instances. Computed state chains (daily score = f(all events + goals)).
**Decision:** Riverpod with riverpod_generator + freezed.
**Alternatives considered:** Bloc, Provider, GetX.
**Rationale:** `family` providers make per-tracker state trivial. Computed state via `ref.watch` chains naturally. Code generation reduces boilerplate. Granular rebuilds by default.
**Consequences:** Steeper initial learning curve. Commits to reactive paradigm throughout app.

### D003 — Firebase over Supabase for backend

**Date:** 2026-04-16
**Status:** Decided
**Context:** Phase 2 needs auth, cloud sync for partner sharing, and potential backup.
**Decision:** Firebase (Auth, Firestore, Cloud Functions).
**Alternatives considered:** Supabase, Appwrite, AWS Amplify.
**Rationale:** Google ecosystem alignment (Android-first, Google Sign-In native). Mature Flutter SDK. Generous free tier. Crashlytics overlap with Sentry for redundancy. Faster to bootstrap for a solo dev.
**Consequences:** NoSQL (Firestore) instead of Postgres — aligns with Isar's NoSQL local model. Less direct SQL access for ML experiments (mitigated by exporting data for analysis separately).

### D004 — No auth in v0.1

**Date:** 2026-04-16
**Status:** Decided
**Context:** Only user is Abhiroop. Auth adds zero value until multi-user or cloud features.
**Decision:** Local-only, no auth for v0.1. Add Firebase Auth in Phase 2.
**Rationale:** Reduces v0.1 scope dramatically. Ship faster. Validate the engine and UX before adding cloud complexity.
**Consequences:** No sharing, no backup, no multi-device sync in v0.1.

### D005 — Config via bundled JSON, not Admin UI, for v0.1

**Date:** 2026-04-16
**Status:** Decided
**Context:** Config Over Code is a core theme, but building a full Admin UI is high effort.
**Decision:** JSON config files in assets/, loaded into Isar on first run. Admin UI deferred.
**Rationale:** Gets config-driven behavior without the UI build cost. Editing JSON is fine for dev-phase. Admin UI is a v0.2 feature.
**Consequences:** Adding a new tracker requires editing JSON + app rebuild (or Shorebird OTA push). Acceptable for solo dev.

### D006 — 9 core themes locked in product DNA

**Date:** 2026-04-16
**Status:** Decided
**Context:** Needed to define the non-negotiable product identity before building.
**Decision:** 9 themes: Frictionless Capture, Instant Reward, Compounding Temporal Narrative, Progressive Disclosure, Config Over Code, Data Sovereignty, Social Accountability, Aesthetic Craft, Ritual Design.
**Rationale:** Each theme is distinct and non-overlapping. Calm Technology folded into Progressive Disclosure. Temporal Narrative merged with Compounding Data (value compounds AND becomes a story). Aesthetic Craft and Ritual Design kept separate (aesthetics = how it looks/feels, ritual = how logging feels as a practice).
**Consequences:** All docs, designs, and implementation decisions must trace back to these themes.
