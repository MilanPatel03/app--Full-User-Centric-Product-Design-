# Design System Specification: The Sacred Editorial

## 1. Overview & Creative North Star
**Creative North Star: "The Digital Sanctuary"**

This design system rejects the frantic, high-density patterns of modern "productivity" apps. Instead, it adopts a **High-End Editorial** approach, treating every screen as a page in a bespoke, limited-edition manuscript. We move beyond "standard" UI by prioritizing breathing room (negative space), intentional asymmetry, and a tactile sense of depth.

To break the "template" look, we utilize **Tonal Layering** and **Large-Scale Typography**. Elements should not feel like they are "trapped" in a grid; they should feel placed with intention, like artifacts on a velvet surface. We favor staggered layouts and overlapping elements over rigid, centered blocks.

---

## 2. Colors & Surface Philosophy

### The "No-Line" Rule
Standard UI relies on borders to separate content. **In this system, 1px solid borders are strictly prohibited for sectioning.** Boundaries are defined exclusively through background shifts using our `surface-container` tiers or subtle tonal transitions. This creates a seamless, organic flow that mimics the continuity of thought and spirit.

### Surface Hierarchy & Nesting
Treat the interface as a physical stack of fine paper.
- **Base Layer:** `surface` (#131313) for the main canvas.
- **Structural Sections:** Use `surface-container-low` (#1C1B1B) to define major content areas.
- **Interactive Layers:** Use `surface-container-highest` (#353534) for cards or floating elements to provide a natural "lift."

### The "Glass & Gradient" Rule
For elements that require a premium, ethereal feel (such as persistent player controls or floating navigation), utilize **Glassmorphism**:
- **Background:** `surface-variant` at 60% opacity.
- **Backdrop Blur:** 20px - 30px.
- **Gradients:** Use a subtle linear gradient from `primary` (#FFC08D) to `primary_container` (#FF9933) on active states and hero CTAs to inject "soul" into the dark canvas.

---

## 3. Typography
The typography scale is designed to balance the ancient authority of the Gita with the modern clarity of a premium app.

| Token | Font | Size | Intent |
| :--- | :--- | :--- | :--- |
| **display-lg** | Noto Serif | 3.5rem | Chapter numbers or Verse starts. |
| **headline-md** | Noto Serif | 1.75rem | Section titles; high-contrast editorial feel. |
| **title-sm** | Noto Serif | 1.0rem | Verse Sanskrit text; authoritative yet readable. |
| **body-lg** | Noto Serif | 1.0rem | Primary translation text; spacious line-height. |
| **label-md** | Inter | 0.75rem | Meta-data, navigation, and UI functional text. |

**Hierarchy Note:** Always pair a large `display` serif with a small `label` sans-serif to create a sophisticated, "curated" contrast.

---

## 4. Elevation & Depth

### The Layering Principle
Depth is achieved through the **Material Stack**. To elevate a verse card, do not reach for a shadow first; instead, place a `surface-container-low` card on top of a `surface_container_lowest` background. This creates "Soft Elevation."

### Ambient Shadows
When a component must float (e.g., a "Current Verse" modal):
- **Blur:** 40px to 60px.
- **Opacity:** 6% - 10%.
- **Shadow Tint:** Use a darkened version of `on_surface` (#E5E2E1) rather than black. This mimics natural light passing through a translucent object.

### The "Ghost Border" Fallback
If accessibility requires a container boundary, use the **Ghost Border**:
- **Token:** `outline_variant` at 15% opacity.
- **Rule:** Never use 100% opaque lines; they "break" the spiritual flow of the layout.

---

## 5. Components

### Buttons
- **Primary:** Filled with `primary_container` (#FF9933). Roundedness: `md` (0.75rem). Text: `on_primary_container` (#693800).
- **Secondary (The Ghost Button):** No fill. `Ghost Border` (15% outline_variant). Subtle hover state using 8% `surface_bright`.
- **Tertiary:** Text-only in `secondary` (Muted Sage). Used for "Skip" or "Back" actions.

### Cards & Verse Containers
- **Construction:** Use `surface-container-high`. No dividers.
- **Spacing:** Minimum 24px internal padding.
- **Asymmetry:** For verse displays, try aligning the Sanskrit text to the right and the English translation to the left to create a premium editorial layout.

### Input Fields
- **Style:** Underline-only or subtle "Surface Shift." Avoid boxed inputs.
- **Active State:** The underline transitions to `primary` (Saffron Gold) with a 2px weight.

### The "Sutra" Progress Bar
- **Design:** A very thin (2px) line using `outline_variant`. The progress indicator is a `primary` glow. No rounded caps; keep it sharp and modern.

---

## 6. Do’s and Don’ts

### Do:
- **Do use generous whitespace.** A verse should have enough room to "breathe" so the user can meditate on the words.
- **Do use Muted Sage (`secondary`) for "Success" or "Calm" states.** It provides a sophisticated alternative to "Standard Green."
- **Do use Noto Serif for all "Wisdom" content.** Inter is strictly for "Utility" (settings, buttons, timestamps).

### Don't:
- **Don't use Divider Lines.** Use a background shift from `surface` to `surface-container-low` to separate sections.
- **Don't use Pure Black (#000).** Our `surface` is #131313 to allow for deep, charcoal textures that feel softer on the eyes.
- **Don't use high-velocity animations.** All transitions should be slow-out (300ms+) to maintain a meditative pace.

---

## 7. Roundedness Scale
| Token | Value | Application |
| :--- | :--- | :--- |
| `sm` | 0.25rem | Tooltips, small tags. |
| `md` | 0.75rem | Primary buttons, Verse cards. |
| `lg` | 1.0rem | Major containers, Bottom sheets. |
| `full` | 9999px | Pills, Selection chips. |