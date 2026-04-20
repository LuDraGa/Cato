# DailyTracker — Product DNA

## What It Is

Config-driven personal metrics engine. Track anything. Visualize everything. Own your data.
Flutter app, local-first (Isar), Android-first. Admin extensibility without code changes.

---

## Core Themes

| # | Theme | Principle |
|---|---|---|
| 1 | **Frictionless Capture** | Every entry < 15 sec. Notification → form → done. No navigation tax. Smart defaults, batch day-end mode, "same as yesterday" for routines. The app meets you where you are — late entry, backfill, edited timestamps — never punishes lateness. |
| 2 | **Instant Reward** | Every tap produces visible change. Heatmap cell fills green. Completion ring advances. Score animates upward. Streak counter bumps. The feedback is immediate, visual, and satisfying — you see proof of your consistency the moment you log. |
| 3 | **Compounding Temporal Narrative** | The app gets more valuable with time, and that value is a *story*, not just a dataset. Week 1 = entries. Month 2 = patterns emerge. Month 6 = correlations across domains. Month 12 = an irreplaceable personal narrative of who you were and how you changed. Weekly Pulse summarizes your week in prose. Compare Weeks shows your arc. The data compounds, and so does its meaning. |
| 4 | **Progressive Disclosure** | Surface is calm. Depth exists behind intent. Five layers: Glance (ring + streak) → Log (entry cards) → Review (heatmaps + trends) → Deep Dive (correlations, overlays) → Admin (config builder). The app offers, then retreats — it never demands attention, never front-loads complexity. Max 2 notifications/day. White cells for missing days (neutral), not red (punitive). Calm technology as an operating principle. |
| 5 | **Config Over Code** | New tracker = JSON config. New visualization = config. A/B test = clone config, assign cohort, measure. The engine is fully polymorphic; the user experience is strictly curated. One dev ships an app that feels like it has a product team, because the architecture does the work. |
| 6 | **Data Sovereignty** | Your data lives on your device. Period. Cloud is opt-in, scoped exclusively to partner sharing and backup. No account required to use the app. No data leaves the device unless you explicitly share it. |
| 7 | **Social Accountability** | Partner sharing — not surveillance. Share heatmaps, weekly pulses, or date-range reports. Granular scope control: choose which domains, what level of detail. Your partner sees your consistency, not your raw entries. Accountability through visibility, not judgment. |
| 8 | **Aesthetic Craft** | <div>Aesthetic Craft is not visual decoration — it is the quiet precision of a well-made object.<br><br>The interface feels composed, not constructed. Every surface carries intention: soft, matte, and gently lit, like paper resting under natural light. Depth exists, but never calls attention to itself.<br><br>Color is restrained. A muted, calm-neutral field — warm cloud, light stone, soft paper — creates serenity, while ink-black is used sparingly — only where attention must land. Accents carry the quiet blue-green of sea glass or morning mist: present but never insisting. Nothing competes.<br><br>Typography anchors the experience in time. Headlines feel architectural, almost editorial; data remains sharp, modern, and efficient. The contrast is deliberate — heritage holding structure, modernity carrying function.<br><br>Motion has weight. Elements don’t move to respond — they settle, glide, and arrive. Transitions feel governed by inertia, not animation curves. The system behaves like matter, not pixels.<br><br>Touch is acknowledged. Interactions offer resistance, subtle and precise — a confirmation that something real has occurred. Not feedback, but response.<br><br>Sound replaces notification with presence. Soft, analog cues — a ceramic tap, a page shifting — reinforce actions without demanding attention. Silence is preserved where possible.<br><br>Space is treated as a material. Interfaces are compact yet breathing — every element is sized to serve, never to impress. Inputs are not crowded; they are presented. The product does less, more clearly.<br><br>Data is drawn, not rendered. Visualizations flow as continuous forms — curves that feel traced rather than computed. No harsh edges, no aggressive signals — only clarity with composure.<br><br>Nothing is ornamental. Nothing is loud. The experience is crafted to feel inevitable.</div> |
| 9 | **Ritual Design** | Daily logging is a deliberate practice, not a chore optimized away. The aesthetic craft, the spring animations, the analog sounds — they exist to make each entry *feel* like something. The difference between gulping coffee at your desk and a slow pour-over. Both get the data in. One builds a habit you look forward to. The cadence of capture, the visual reward, the calm surface — together they make logging a ritual, not a task. |

---

## Value Propositions

| For | Value |
|---|---|
| **Self-trackers** | One app for everything. No more 5 separate apps for meals, workouts, mood, sleep, habits. |
| **Data nerds** | Cross-domain correlation. "Does my sleep improve when I work out?" — answered with your own data. |
| **Couples** | Shared accountability without micromanagement. See partner's consistency, not their raw data. |
| **Dev (you)** | Config-driven = fast iteration. Ship tracker experiments via OTA without app store deploys. |

---

## Retention Mechanics

```
DAY 1          WEEK 2           MONTH 2          MONTH 6+
Entry works    Streak hurts     Patterns emerge   Narrative is
  ↓            to break           ↓              irreplaceable
Simple           ↓             Correlations         ↓
utility      Loss aversion     drive curiosity   Lock-in via
                                                 compounding story
```

---

## Anti-Patterns (What This App Will Never Do)

- Guilt messaging ("You're falling behind!")
- Public leaderboards or social comparison
- Badge/achievement bloat
- Notification spam (hard cap: 2/day)
- Punitive visuals for missed days (white = empty, not red = failure)
- Require internet to function
- Synthetic gamified sounds or visuals
- Flat, soulless UI with no material depth
