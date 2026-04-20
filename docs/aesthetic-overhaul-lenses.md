# Aesthetic Overhaul Lenses

**Date:** 2026-04-19
**Status:** Living design evaluation framework
**Purpose:** When any part of Cato feels off, these six lenses provide a systematic way to identify _what_ is wrong, _why_ it breaks, and _how_ to fix it consistently. This is not a task list. It is an evaluation methodology.

**Relationship to Product DNA:** The Product DNA's Aesthetic Craft theme (Theme 8) describes the _philosophy_. These lenses operationalize it into evaluable dimensions. Each lens is anchored to a specific line from the Aesthetic Craft description and the Ritual Design theme.

---

## Table of Contents

1. [Spatial Composition](#lens-1-spatial-composition)
2. [Interaction Physics](#lens-2-interaction-physics)
3. [Surface & Material](#lens-3-surface--material)
4. [Motion & Time](#lens-4-motion--time)
5. [Visual Hierarchy](#lens-5-visual-hierarchy)
6. [Sensory Feedback](#lens-6-sensory-feedback)
7. [How to Use This Framework](#how-to-use-this-framework)
8. [Decision Log](#decision-log)

---

## Lens 1: Spatial Composition

**Anchor:** _"Space is treated as a material. Interfaces open with breathing room, isolating what matters."_

### What it evaluates

How information is arranged in space — both within a single screen and across the navigation structure. The spatial organization of data, the hierarchy of elements, and how the user moves through the information landscape.

### Core principle

Space is not the absence of content. It is content. Every gap, margin, and grouping carries meaning. Elements should be spatially organized so the eye naturally flows to what matters, and the mind can build a mental model of where things are.

### The test

- Does the screen have a clear focal point, or does the eye wander?
- Is there a single primary object above the fold?
- Can the user find information from 6 months ago without scrolling through everything in between?
- Does the spatial layout scale? What happens with 1 item? 10 items? 50 items?
- If you removed all text and color, would the layout alone communicate hierarchy?
- Does navigation between data feel like turning pages in a book, or scrolling a feed?

### What "right" feels like

You see a screen and your eye lands exactly where it should. Nothing competes. Moving to related content feels like panning a camera — you understand where you are in the larger space. You never feel lost in an endless scroll.

### What "wrong" feels like

Everything is stacked vertically. Scroll to find things. The screen is either too empty (wasted space) or too full (visual noise). Navigation is additive — "show more" buttons that just make the page longer. No sense of spatial permanence — things appear and disappear without spatial logic.

### Reference anchors

- A well-designed book: chapters, sections, pages give spatial structure to linear content
- An instrument panel: each gauge has a fixed position you learn to glance at
- A calendar on a wall: months are spatial regions, not a feed

---

## Lens 2: Interaction Physics

**Anchor:** _"Touch is acknowledged. Interactions offer resistance, subtle and precise — a confirmation that something real has occurred."_

### What it evaluates

How every input, gesture, and interaction _feels_ in the user's hands. The physical quality of touching, dragging, scrolling, and selecting. Whether inputs feel like manipulating physical objects or clicking digital buttons.

### Core principle

Every interaction should feel like it has mass and inertia. Inputs should resist, settle, and respond — not snap, jump, or ignore. The difference between turning a dial and clicking a checkbox. Both set a value; one feels like you touched something real.

### The test

- Does the input feel continuous or discrete? If discrete, is the stepping justified by the data, or is it a technical limitation?
- When you drag or scroll, does the element track your finger with appropriate resistance, or does it feel weightless/sticky?
- Can the user achieve any valid value, or are they constrained to a predefined grid?
- Does the input communicate its current state through physical metaphor (position, weight, resistance)?
- Is there a haptic or visual response at the moment of commitment (not just at the moment of interaction)?
- Would a blindfolded user understand what they just did from haptic feedback alone?

### What "right" feels like

Setting a score feels like turning a volume knob — smooth, continuous, with subtle resistance at each position. Entering a time feels like moving clock hands — fluid, circular, with the number updating as your finger moves. Saving an entry feels like setting down a stone — a brief, satisfying moment of weight.

### What "wrong" feels like

A picker snaps between values with no intermediate states. An input opens a system dialog that breaks immersion. A slider has no thumb, no weight, no sense of physical control. Tapping a button produces no feedback — visual, haptic, or auditory — until the result appears.

### Reference anchors

- A mechanical watch crown: smooth rotation with click detents
- A camera lens ring: continuous, precise, physically satisfying
- A ceramic light switch: one decisive moment of commitment

---

## Lens 3: Surface & Material

**Anchor:** _"Every surface carries intention: soft, matte, and gently lit, like paper resting under natural light. Depth exists, but never calls attention to itself."_

### What it evaluates

The physical quality of every visible element — its material, its edges, its relationship to light. Whether elements read as real objects with presence, or as colored rectangles on a screen.

### Core principle

Every surface should feel like it was made of something. Paper, ceramic, frosted glass, brushed stone. This isn't about skeuomorphism — it's about material intention. A button should feel different from a card. A card should feel different from the background. These differences should be communicated through shadow, border, texture, and response to interaction — not just through color. The palette favors calm neutrals over earthy pigments — warm cloud, light stone, soft paper — with accents that carry the quiet blue-green of sea glass: soothing, not asserting.

### The test

- If you described this element to someone, would you say "a card" or "a white rectangle with rounded corners"? The former means it has material presence; the latter means it doesn't.
- Does the element have appropriate edge treatment? (Subtle border, shadow, or both)
- Does the element respond to interaction with a material-consistent state change? (Shadow recession on press, color shift, etc.)
- Is the element's elevation consistent with its role? (Interactive elements elevated, completed elements receded, at-rest elements flat)
- Would this element feel at home in a Japanese stationery store? (Matte, considered, quiet)

### What "right" feels like

You look at a card and it feels like a note card sitting on a desk. You tap it and the shadow shifts as if you pressed it down. The surface has just enough texture to feel real without being decorative.

### What "wrong" feels like

Elements are flat colored shapes. No borders, or borders that feel like wireframes. Shadows that don't respond to interaction. Buttons that look identical to labels. Everything at the same visual "elevation" — nothing comes forward, nothing recedes.

### Reference anchors

- Muji product packaging: clean, matte, material-aware
- A stack of quality paper: each sheet has edge, shadow, weight
- Ceramic tiles: surface variation within a unified material language

---

## Lens 4: Motion & Time

**Anchor:** _"Motion has weight. Elements don't move to respond — they settle, glide, and arrive. Transitions feel governed by inertia, not animation curves."_

### What it evaluates

How elements move, appear, disappear, and transition between states. Whether animations feel like physical motion or digital effects. How the system communicates the passage of time and the processing of actions.

### Core principle

Motion should feel like the consequence of physical forces, not the execution of code. Things have mass, so they accelerate slowly and decelerate smoothly. Things have friction, so they settle rather than bounce. The system "absorbs" actions — there's a brief moment between your input and the result where you can feel the system processing, like dropping a coin into a well and waiting for the splash.

### The test

- Does the animation feel like physics or like a tween? (Spring vs. linear/cubic)
- Is there appropriate lag between cause and effect? (50-150ms of "absorption time")
- Do related elements animate in sequence (stagger) or simultaneously? Simultaneous updates feel instantaneous/digital; staggered updates feel like a system settling.
- Could you describe the motion with a physical metaphor? ("The ring sweeps like a gauge needle" vs. "the progress bar updates")
- Is the animation's duration proportional to the action's importance? (Micro-actions = fast, significant commits = medium, rare milestones = slow)
- Does the exit animation feel as considered as the entrance animation?

### What "right" feels like

After saving an entry, the sheet slides away, then the card settles into its new state, then the ring sweeps to its new position, then the score counts up. Each step is brief but perceptible. The whole sequence takes under a second but feels like the system digested your input.

### What "wrong" feels like

Everything updates at once — tap, and the screen jumps to its new state. Or: nothing animates at all. Or: animations are present but feel decorative — a bounce here, a fade there — with no physical logic connecting them.

### Reference anchors

- A mechanical scoreboard flipping to a new number: sequential, weighted
- A compass needle settling on north: overshoot, dampen, arrive
- Water settling after a drop: ripple, then calm

---

## Lens 5: Visual Hierarchy

**Anchor:** _"The interface feels composed, not constructed."_

### What it evaluates

The typographic, chromatic, and spatial hierarchy of information on every screen. Whether the eye is guided or left to fend for itself. Whether the design feels intentionally arranged or merely laid out.

### Core principle

Every screen is a composition, not a stack of widgets. There is one hero, one supporting cast, and one background. Typography creates three layers: headlines that anchor (serif, architectural), body that communicates (sans, clear), and captions that whisper (sans, muted). Color reinforces this: ink-black for focal data, warm charcoal for readable content, warm grays for progressive de-emphasis. The accent (mist sage) appears only at points of progress or interaction — never competing with the hero. Nothing competes with the hero.

### The test

- Can you identify the single most important piece of information on this screen in under 1 second?
- Are there exactly three typographic "weights" visible — loud, normal, quiet? If more, the hierarchy is muddy. If fewer, it's flat.
- Is serif reserved for structural elements (headers, titles, names) and sans for functional elements (data, labels, inputs)?
- Does the color usage follow the ink-black > primary > secondary > tertiary cascade, with ink-black appearing in only 1-2 places per screen?
- Is there clear visual grouping? Can you draw boxes around related elements, or does everything float independently?
- Does the white space between groups communicate "these are separate" while the space within groups communicates "these belong together"?

### What "right" feels like

Your eye traces a clear path: hero > context > action > details. Nothing screams. Nothing hides that shouldn't. The screen feels like a magazine spread — everything placed with intention.

### What "wrong" feels like

Multiple elements compete for attention. Typography sizes are too similar (everything's 14-18px). Ink-black is used on too many things (nothing stands out when everything stands out). Sections blur together because spacing is uniform.

### Reference anchors

- A newspaper front page: headline, subhead, body, caption — four clear levels
- A museum label: title, artist, medium, date — each at a different visual weight
- A well-set dining table: each object has a position that relates to every other object

---

## Lens 6: Sensory Feedback

**Anchor:** _"Sound replaces notification with presence. Soft, analog cues reinforce actions without demanding attention."_

### What it evaluates

The haptic, auditory, and micro-visual feedback layer — the responses that confirm "something real has occurred" without demanding conscious attention. The texture of the experience.

### Core principle

Feedback should be felt, not noticed. The goal is presence, not notification. A subtle haptic tick confirms each slider step the way a mechanical dial clicks. A soft sound on save confirms commitment the way closing a book confirms you're done. These signals work below the threshold of conscious attention — you'd notice their absence before you'd notice their presence.

### The test

- Does the most important action (save) have the richest feedback? (haptic + optional sound + visual state change)
- Does feedback match the physical metaphor? (Slider = tick. Toggle = click. Save = impact. Error = nothing — the system does not punish.)
- Is feedback absent where it should be? (No haptic on navigation, no haptic on error, no sound on sheet open)
- Is the feedback hierarchy correct? (Light for micro-actions, medium for commits, heavy for rare milestones)
- Are there zero cases of haptic/sound playing when the user didn't initiate an action?
- Could someone hearing-impaired get full feedback from haptics alone? Could someone with motor sensitivity use the app with sound alone?

### What "right" feels like

You log an entry and feel a brief, clean vibration paired with a quiet ceramic tap (if sound is on). The combination is so natural you don't think about it. On your 30th consecutive day, you feel a heavier impact — something landed. You know it was special without reading a message.

### What "wrong" feels like

Haptics feel arbitrary — some things vibrate, others don't. Sounds are synthetic (beeps, chimes, whooshes). Error states produce haptic punishment. Navigation produces unnecessary noise. Or: nothing responds at all, and the app feels like pushing buttons in a vacuum.

### Reference anchors

- A quality mechanical keyboard: each keystroke has consistent, satisfying feedback
- A Leica shutter: one precise, brief, unmistakable moment
- A door latch clicking closed: confirmation through feel, not sound

---

## How to Use This Framework

### When something feels off

1. **Name the discomfort.** "This doesn't feel right" is too vague. Sharpen it: "This feels flat / busy / mechanical / lost / arbitrary / silent."
2. **Identify the lens.** Each adjective maps to a lens:
   - _Flat / lifeless_ — Surface & Material (Lens 3)
   - _Busy / cluttered / noisy_ — Visual Hierarchy (Lens 5) or Spatial Composition (Lens 1)
   - _Mechanical / snappy / weightless / clunky_ — Interaction Physics (Lens 2) or Motion & Time (Lens 4)
   - _Lost / disoriented / overwhelmed_ — Spatial Composition (Lens 1)
   - _Arbitrary / inconsistent / unfinished_ — any lens; check all six
   - _Silent / dead / hollow_ — Sensory Feedback (Lens 6)
3. **Run the test questions** for that lens against the specific element.
4. **Define the gap** between current state and what "right" feels like.
5. **Design the fix** using the reference anchors as calibration.
6. **Verify the fix doesn't break other lenses.** A richer surface (Lens 3) shouldn't create visual noise (Lens 5). A satisfying animation (Lens 4) shouldn't slow down the interaction (Lens 2).

### When lenses conflict

Lenses sometimes pull in opposite directions. Resolution principles:

- **More material depth (Lens 3) vs. visual noise (Lens 5):** Depth through shadow and border, not color. Keep the chromatic palette flat; let elevation do the work.
- **Richer motion (Lens 4) vs. interaction speed (Lens 2):** Animation runs _after_ the input is committed, never _before_ or _during_ the input. The user is never waiting for an animation to finish before they can act.
- **Richer feedback (Lens 6) vs. sensory clutter:** Max two feedback channel per micro-action (haptic OR visual). Reserve multi-channel feedback (haptic + sound + visual) for the save moment only.

### Lens priority (when in doubt)

```
Interaction Physics (2) > Spatial Composition (1) > Visual Hierarchy (5)
  > Surface & Material (3) > Motion & Time (4) > Sensory Feedback (6)
```

The thing that matters most is that interactions feel right in your hands. The thing that matters least is the sound it makes. Every lens matters, but when you must trade off, this is the order.

### Applying to a new element

Before building any new UI element, run it through all six lenses as a pre-flight:

1. **Spatial:** Where does it live in the screen? What's above, below, beside it? Does it have breathing room?
2. **Physics:** How does the user interact with it? Does it feel continuous or discrete? What resists, what yields?
3. **Surface:** What is it made of? What's its elevation? How do its edges read?
4. **Motion:** How does it arrive? How does it leave? How does it change state?
5. **Hierarchy:** What typographic level is its text? What color weight? Does it compete with the hero?
6. **Sensory:** What feedback does it produce? Haptic? Sound? Nothing?

---

## Decision Log

Concrete design decisions made through the lens framework. Each entry records what was evaluated, which lens applied, what was decided, and why.

_Decisions are added here as they are made through discussion. This section starts empty._

<!-- Template:
### [Element/Screen Name] — [Date]
**Lens:** [which lens(es)]
**Issue:** [what felt off]
**Decision:** [what we chose]
**Why:** [reasoning through the lens]
-->
