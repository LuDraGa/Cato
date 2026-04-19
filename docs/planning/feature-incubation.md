# Feature Incubation — R&D Log

**Status:** Planning
**Dependencies:** product-dna.md (features must trace to a core theme)

---

*A structured log for brainstorming features before any code is written. Each idea gets a What, Why, and How (implementation theory) plus kill criteria. Keeps ideation disciplined and traceable to the DNA.*

---

## Template

```
### [FEATURE_NAME]

**Status:** Idea | Researching | Spec'd | Building | Shipped | Killed
**Theme:** (which Product DNA theme does this serve?)
**Priority:** P0 (MVP) | P1 (Soon) | P2 (Later) | P3 (Someday)

**What:** One sentence. What does the user experience?

**Why:** Why does this matter? What behavior does it drive?

**How (Implementation Theory):**
- Data model impact:
- Engine/layer affected:
- Key packages or APIs:
- Estimated complexity: Low | Medium | High

**Open Questions:**

**Kill Criteria:** What would make us NOT build this?
```

---

## Features to Incubate

- [ ] Heatmap calendar (GitHub-style, per-tracker + global)
- [ ] Streak counter and streak mechanics
- [ ] Completion ring (today's progress)
- [ ] Daily composite score (animated)
- [ ] Quick-entry from push notification
- [ ] Batch day-end entry mode
- [ ] Backfill via heatmap tap
- [ ] "Same as yesterday" quick-repeat
- [ ] Weekly Pulse auto-summary
- [ ] Compare Weeks chunk view
- [ ] Multi-metric overlay charts with normalization
- [ ] Partner shared heatmap / pulse
- [ ] Shorebird OTA config push
- [ ] PDF export of visualizations
- [ ] Correlation insights engine
- [ ] Celebration micro-animations (streak milestones)
- [ ] Dev panel (Isar browser, seed data, config viewer)

---

*Use the template above to flesh out each feature when it's time to work on it. Don't pre-fill — discuss first.*
