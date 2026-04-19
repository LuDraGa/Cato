# Complex Behaviors

**Status:** Planning
**Dependencies:** product-dna.md (all 9 themes inform trade-offs here)

---

_This doc sits outside any single layer. Each behavior is a cross-cutting problem where user flow, product decisions, aesthetic intent, and technical constraints collide. The goal is to balance the DNA themes and reach the most optimal, feasible, implementable outcome — documenting the compromises made and why._

---

## Behaviors to Work Through

- [ ] On-device storage + real-time-feeling partner sharing (the sync paradox: Isar local-first vs Firebase Firestore for sharing perms and data slices)
- [ ] Config-driven dynamic form rendering with validation (how InputField schema becomes UI, handles required/optional, composite inputs, and stays aesthetic)
- [ ] Heatmap aggregation across different tracker frequencies (daily tracker vs multi-daily meals vs weekly trackers — one heatmap model or many?)
- [ ] Schema evolution (admin changes tracker config, old events still exist — migration, backward compat, or versioned display?)
- [ ] Backfill semantics (does a backfilled entry count toward streaks? daily score? how does it surface in the temporal narrative?)
- [ ] Normalization for multi-metric overlays (sleep score 1-10 vs pushups 0-100 vs duration in minutes — what normalization preserves meaning?)
- [ ] Notification scheduling (prompt time vs effective time vs entry time — three timestamps, one UX that feels simple)
- [ ] Offline-first conflict resolution (user edits on device A, shares from device B — what wins? does this even matter in Phase 1?)
- [ ] Mood input innovation (how to capture mood without boring 1-5 scales — contextual questions, but how does that feed into quantitative viz?)
- [ ] Photo storage and lifecycle (local media paths, storage limits, compression, gallery view, what happens when device storage fills?)
- [ ] Composite input rendering (sleep = duration + freshness + latency + wake quality — one card or multi-step? how to keep it < 15 sec?)
