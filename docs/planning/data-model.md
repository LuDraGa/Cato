# Data Model

**Status:** Planning
**Dependencies:** product-dna.md, complex-behaviors.md
**Feeds into:** technical-manifest.md, implementation

---

*Isar schema reference. The config-driven architecture means the data model IS the product — how Domain, Tracker, Event, and MetricValue relate determines what's possible.*

---

## To Define

- [ ] Collection schemas (Domain, Tracker, Event, MetricValue, AppConfig)
- [ ] Polymorphic MetricValue strategy (type discrimination in Isar embedded objects)
- [ ] InputField schema (the config that drives dynamic form rendering)
- [ ] Index strategy (effectiveDate, trackerId, composites)
- [ ] Constraints (unique daily entries per tracker? or allow multiples for meals?)
- [ ] Schema evolution / migration strategy (tracker config changes vs existing events)
- [ ] SharedView model for partner sharing (Phase 2 — scoping, access levels)
- [ ] Relationship between local Isar collections and Firebase cloud documents
- [ ] Seed data format (JSON config structure for initial trackers)
