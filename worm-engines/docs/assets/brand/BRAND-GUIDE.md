# WORM Engines Brand Guide

**Repository:** https://github.com/SNAPKITTYWEST/worm-engines  
**Version:** 1.0  
**Date:** 2026-07-29

---

## Emblem Meaning

The WORM Engines mark consists of three interlocking angular links arranged in an ascending chain:

| Element | Meaning |
|---------|---------|
| **Continuity** | Write-once record progression through the append-only ledger |
| **Interlock** | Cross-language integration (Zig, Ada/SPARK, Erlang, OCaml, C ABI) |
| **Closed geometry** | Integrity preservation and invariant protection |
| **Metallic surface** | Durability and infrastructure-grade reliability |
| **Purple core** | Formal verification and policy intelligence |
| **Center dot** | Integrity point — cryptographic commitment |

---

## Color Palette

### Primary Colors

| Name | Hex | Usage |
|------|-----|-------|
| **Background Black** | `#050507` | Primary background |
| **Background Dark** | `#111116` | Secondary background, panels |
| **Metallic** | `#E7E7EA` | Primary accent, emblem stroke |
| **Purple Primary** | `#8B5CF6` | Accent color, tagline text |
| **Purple Dark** | `#4C1D95` | Dividers, subtle accents |
| **Muted Gray** | `#8A8A96` | Body text, labels |

### Gradients

- **Metallic Gradient**: `#E7E7EA` → `#D0D0D8` → `#B8B8C0` (emblem metallic effect)
- **Purple Glow**: `#8B5CF6` (center, 30% opacity) → transparent (radial)

---

## Typography

### Typeface Fallback Stack

```
-apple-system, BlinkMacSystemFont, "Segoe UI", monospace
```

### Styles

| Usage | Font Size | Weight | Letter Spacing | Color |
|-------|-----------|--------|-----------------|-------|
| **Title** | 80px | 800 | 8px | `#E7E7EA` |
| **Primary Tagline** | 24px | 700 | 3px | `#8B5CF6` |
| **Secondary Tagline** | 16px | 400 | 2px | `#A0A0A8` |
| **Capability Labels** | 11px | 700 | 1px | `#E7E7EA` |
| **Language Labels** | 10px | 400 | 0.5px | `#A0A0A8` |

---

## Asset Specifications

### Hero Image (1600×900)

- **File:** `worm-engines-hero.svg`
- **Format:** SVG with embedded styles
- **Use:** GitHub README header, landing pages, documentation
- **Rendering:** Responds to light and dark themes via CSS
- **Safe margins:** 80px from edges for important text

### Repository Mark (512×512)

- **File:** `worm-engines-mark.svg`
- **Format:** SVG with transparent background
- **Use:** Repository favicon, navigation icons, social avatars
- **Minimum size:** 32×32 pixels (remains recognizable)
- **Variants:** Color and monochrome

### Monochrome Mark (512×512)

- **File:** `worm-engines-mark-mono.svg`
- **Format:** SVG, single-color metallic
- **Use:** Terminal output, documentation, print, seals
- **Color:** `#E7E7EA` (metallic)

### Favicon (64×64)

- **File:** `worm-engines-favicon.png`
- **Format:** PNG, 8-bit RGB
- **Use:** Browser tab icon
- **Background:** Transparent

---

## Clear Space

Minimum clear space around the emblem: **40 pixels** on all sides (for the 512×512 mark).

When scaling down, reduce proportionally but never below 32×32 display size.

---

## Display Guidelines

### Light Background

- Use metallic (`#E7E7EA`) for primary strokes
- Use purple (`#8B5CF6`) for accents
- Maintain minimum contrast ratio of 4.5:1

### Dark Background

- Use metallic (`#E7E7EA`) for primary strokes
- Use purple (`#8B5CF6`) for accents (same palette)
- Background should be near-black (`#050507` or darker)

### Monochrome (Print / Terminal)

- Use `#E7E7EA` (metallic) on any background
- Use `#000000` (black) on light backgrounds
- Minimum stroke width: 1.5px at actual size

---

## Prohibited Modifications

❌ Do not alter the interlocking geometry  
❌ Do not add drop shadows or excessive blur  
❌ Do not change the emblem color to non-brand colors  
❌ Do not stretch or distort the mark  
❌ Do not add cryptocurrency, blockchain, or coin imagery  
❌ Do not remove or modify the integrity center dot  
❌ Do not change the interlock direction or sequence  
❌ Do not add text directly on the emblem  

---

## Repository Asset Paths

Place all assets in this directory structure:

```
docs/
└── assets/
    └── brand/
        ├── worm-engines-hero.svg          (1600×900 hero)
        ├── worm-engines-social.png        (1280×640 social preview)
        ├── worm-engines-mark.svg          (512×512 color emblem)
        ├── worm-engines-mark-mono.svg     (512×512 monochrome)
        ├── worm-engines-favicon.png       (64×64 favicon)
        └── BRAND-GUIDE.md                 (this file)
```

---

## README Integration

Insert the hero image at the top of README.md:

```markdown
<p align="center">
  <img
    src="docs/assets/brand/worm-engines-hero.svg"
    alt="WORM Engines — verifiable, durable, multi-language append-only ledger fabric"
    width="100%"
  />
</p>
```

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-07-29 | Initial release — Hero, mark (color + mono), favicon, brand guide |

---

## Contact

For brand usage questions, contact: **branding@snapkittywest.dev**

---

**WORM Engines Brand Identity**  
Designed for enterprise infrastructure. Built with precision.
