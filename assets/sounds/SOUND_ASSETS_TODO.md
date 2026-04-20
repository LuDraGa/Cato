# Sound Assets TODO

Each pack needs 5 sounds in `.ogg` format, under 50KB each.
Pre-load at app init for sub-50ms latency.

## Sourcing Strategy

### Gold Standard Sources
- **Google Material Design Sound Resources** — best match for Ceramic and Glass packs
- **freesound.org** — CC-licensed, filter by rating, search CC0
- **pixabay.com/sound-effects** — royalty-free, no attribution required
- **zapsplat.com** — free with attribution, paid for no-attribution

### Search Terms by Pack

#### Ceramic (Google Material Design first)
- `tick` → "Ceramic Click", "Porcelain Tap", "Cup on Saucer"
- `save` → "Ceramic Tap", "Pottery Bowl Tap"
- `complete` → "Bowl Resonance", "Ceramic Bowl Strike"
- `milestone` → "Stacking Bowls", "Double Ceramic Hit"
- `delete` → "Ceramic Scrape", "Pottery Slide"

#### Paper (The "Stationery" Pack)
- `tick` → "Pencil Dot", "Graphite Tap"
- `save` → "Single Page Turn"
- `complete` → "Moleskine Close", "Book Shut", "Journal Close"
- `milestone` → "Paper Stamp", "Seal Press"
- `delete` → "Paper Tear Perforated", "Gentle Rip"

#### Water
- `tick` → "Bubble Pop", "Tiny Water Drip"
- `save` → "Single Water Drop Pool", "Water Plop"
- `complete` → "Two Drops Sequence", "Drip Drip"
- `milestone` → "Stream Over Stones", "Gentle Brook"
- `delete` → "Water Drain", "Receding Water"

#### Wood (The "Zen" Pack)
- `tick` → "Clave Hit", "Chopstick Click"
- `save` → "Bamboo Knock", "Hollow Wood Tap"
- `complete` → "Wooden Box Close", "Wood Lid Click"
- `milestone` → "Mokugyo", "Temple Block", "Wood Block Strike"
- `delete` → "Drawer Slide Close", "Wood Friction"

#### Bell
- `tick` → "Wind Chime Single", "Small Bell Ting"
- `save` → "Singing Bowl Small Strike"
- `complete` → "Singing Bowl Medium", "Tibetan Bowl"
- `milestone` → "Temple Bell", "Bonshō Strike"
- `delete` → "Dampened Chime", "Muted Bell"

#### Glass (Google Material Design first)
- `tick` → "Glass Marble Click", "Bead Touch"
- `save` → "Wine Glass Rim Tap", "Crystal Tap"
- `complete` → "Glass Clink Toast", "Crystal Touch"
- `milestone` → "Crystal Bowl Singing", "Wet Finger Glass"
- `delete` → "Glass Bead Rolling", "Marble Roll"

#### Textile (The "Cozy" Pack)
- `tick` → "Thread Snap", "Cloth Click"
- `save` → "Fabric Fold", "Linen Movement"
- `complete` → "Blanket Settle", "Throw Landing"
- `milestone` → "Ribbon Pull", "Satin Slide"
- `delete` → "Soft Velcro Rip" (shortened to 100ms)

## Format Requirements
- Format: `.ogg` (Android-native, zero decode latency)
- Each sound: <50KB
- Full pack: <500KB
- Trim silence, normalize peaks, fade out tails
- Convert: `ffmpeg -i input.mp3 -c:a libvorbis -q:a 3 -t 0.5 output.ogg`

## Per-Pack Detailed Descriptions

### ceramic/
- `save.ogg` — Single ceramic tap, like setting a cup on a saucer. ~150ms.
- `complete.ogg` — Deeper ceramic bowl tap, rounder. ~300ms with decay.
- `milestone.ogg` — Two quick taps (low then high), like stacking bowls. ~400ms.
- `tick.ogg` — Tiny porcelain click, ceramic bead. ~50ms. Non-fatiguing.
- `delete.ogg` — Soft ceramic scrape, receding. ~200ms.

### paper/
- `save.ogg` — Single page turn, quality paper settling. ~200ms.
- `complete.ogg` — Soft book closing, journal shutting. ~350ms.
- `milestone.ogg` — Paper stamp impression, seal pressed. ~300ms.
- `tick.ogg` — Pencil mark, graphite stroke. ~40ms.
- `delete.ogg` — Gentle paper tear, perforated edge. ~250ms.

### water/
- `save.ogg` — Single drop into still pool, with ripple. ~250ms.
- `complete.ogg` — Two drops in sequence, different pitches. ~400ms.
- `milestone.ogg` — Brief stream over stones, fading. ~500ms.
- `tick.ogg` — Tiny bubble pop, subliminal. ~30ms.
- `delete.ogg` — Water draining gently. ~300ms.

### wood/
- `save.ogg` — Bamboo knock, hollow and warm. ~180ms.
- `complete.ogg` — Wooden box lid settling. ~250ms.
- `milestone.ogg` — Temple woodblock (mokugyo) strike. ~500ms.
- `tick.ogg` — Chopstick tap, two thin sticks. ~40ms.
- `delete.ogg` — Wooden drawer sliding closed. ~300ms.

### bell/
- `save.ogg` — Small singing bowl, soft strike. ~400ms.
- `complete.ogg` — Medium singing bowl, deeper. ~600ms.
- `milestone.ogg` — Temple bell (bonshō), deep. ~800ms.
- `tick.ogg` — Tiny wind chime, single high note. ~60ms.
- `delete.ogg` — Dampened bell, ring cut short. ~150ms.

### glass/
- `save.ogg` — Wine glass rim tap, crystal. ~200ms.
- `complete.ogg` — Two glasses touching, soft toast. ~300ms.
- `milestone.ogg` — Crystal bowl singing, pure tone swell. ~500ms.
- `tick.ogg` — Glass marble click, two beads. ~30ms.
- `delete.ogg` — Glass bead rolling and stopping. ~250ms.

### textile/
- `save.ogg` — Cloth fold, quality linen. ~200ms.
- `complete.ogg` — Blanket settling on surface. ~350ms.
- `milestone.ogg` — Ribbon pull through fabric. ~400ms.
- `tick.ogg` — Thread snap/pluck. ~25ms.
- `delete.ogg` — Very gentle velcro whisper. ~150ms.
