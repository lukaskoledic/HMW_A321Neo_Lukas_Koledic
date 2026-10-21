# HMW A321neo — Asset Reuse Register

**Project Directory:** `/Users/lukas/X-Plane 12/Aircraft/HMW_A321Neo_AppleSilicon_Dev/`
**Assessment Date:** 2026-10-21
**Status:** Internal development copy — NOT for redistribution until licensing review is complete

---

## 1. HMW Original Assets (Project-Owned)

| Asset Path | Source | Author | License | Modifiable? | Redistributable? | Attribution Required? |
|------------|--------|--------|---------|-------------|------------------|----------------------|
| `A321.acf` | HMW project | HMW contributors | GPL v3 | YES | YES | Yes (HMW contributors) |
| `plugins/sasl/data/modules/Custom Module/*.lua` | HMW project | HMW contributors | GPL v3 | YES | YES | Yes (HMW contributors) |
| `documentation/*.md` | HMW project | HMW contributors | GPL v3 | YES | YES | Yes (HMW contributors) |
| `CONTRIBUTING.md`, `README.md`, `ACKNOWLEDGMENTS.md` | HMW project | HMW contributors | GPL v3 | YES | YES | Yes (HMW contributors) |

---

## 2. HMW Aircraft Objects (Jonathan Orr-derived — DO NOT MODIFY)

| Asset Path | Source | Author | License | Modifiable? | Redistributable? | Attribution Required? |
|------------|--------|--------|---------|-------------|------------------|----------------------|
| `objects/legacy/*.obj` | Jonathan Orr | Jonathan Orr | CC BY-NC-ND 4.0 | **NO** | YES (non-commercial) | Yes (Jonathan Orr) |
| `objects/legacy/texture/*.png` | Jonathan Orr | Jonathan Orr | CC BY-NC-ND 4.0 | **NO** | YES (non-commercial) | Yes (Jonathan Orr) |
| `objects/cockpit_obj/*.obj` | Jonathan Orr | Jonathan Orr | CC BY-NC-ND 4.0 | **NO** | YES (non-commercial) | Yes (Jonathan Orr) |
| `objects/cockpit_interior_obj/*.obj` | Jonathan Orr | Jonathan Orr | CC BY-NC-ND 4.0 | **NO** | YES (non-commercial) | Yes (Jonathan Orr) |
| `objects/cup.obj` | Jonathan Orr | Jonathan Orr | CC BY-NC-ND 4.0 | **NO** | YES (non-commercial) | Yes (Jonathan Orr) |
| `objects/ext lights.obj` | Jonathan Orr | Jonathan Orr | CC BY-NC-ND 4.0 | **NO** | YES (non-commercial) | Yes (Jonathan Orr) |
| `objects/particles/particles.obj` + `.png` | Jonathan Orr | Jonathan Orr | CC BY-NC-ND 4.0 | **NO** | YES (non-commercial) | Yes (Jonathan Orr) |
| `objects/texture/Cup.png`, `Cup_NML.png` | Jonathan Orr | Jonathan Orr | CC BY-NC-ND 4.0 | **NO** | YES (non-commercial) | Yes (Jonathan Orr) |
| `objects/windows_textures/*.png` | Jonathan Orr | Jonathan Orr | CC BY-NC-ND 4.0 | **NO** | YES (non-commercial) | Yes (Jonathan Orr) |
| `objects/LICENSE` | Jonathan Orr | Jonathan Orr | CC BY-NC-ND 4.0 | N/A | N/A | Yes (Jonathan Orr) |

**Critical:** These assets cannot be modified. Any work on them must be done in separate files or by creating replacement geometry.

---

## 3. Third-Party Assets Imported Into Project

### 3.1 Landing Gear Assembly (A321_Mod)

| Asset Path | Source | Author | License | Modifiable? | Redistributable? | Attribution Required? |
|------------|--------|--------|---------|-------------|------------------|----------------------|
| `objects/LandingGears.obj` (incl. merged door geometry) | A321_Mod | Josh Davidson, Jonathan Redpath, merspieler, Matthew Maring, Thorsten Herrmann, Semir Gebran | GPL v2 | **YES** | YES | Yes (6 authors) |
| `objects/LandingGears.png` | A321_Mod | Same as above | GPL v2 | **YES** | YES | Yes (6 authors) |
| `objects/LandingGears_NRM.png` | A321_Mod | Same as above | GPL v2 | **YES** | YES | Yes (6 authors) |

**Source:** `/Users/lukas/Desktop/A321_Mod/objects/`
**Evidence:** A321_Mod root `LICENSE` file (GPL v2), `README.copyright.md`

---

### 3.2 Sound Assets (FMOD Bank)

| Asset Path | Source | Author | License | Modifiable? | Redistributable? | Attribution Required? |
|------------|--------|--------|---------|-------------|------------------|----------------------|
| `fmod/*.bank`, `fmod/*.snd` | A32NX project | A32NX contributors | CC BY-NC-SA 4.0 | YES | YES (non-commercial, share-alike) | Yes (A32NX contributors) |
| `fmod/LICENSE` | A32NX project | A32NX contributors | CC BY-NC-SA 4.0 | N/A | N/A | Yes |

**Evidence:** `fmod/LICENSE` file

---

### 3.3 SASL Plugin

| Asset Path | Source | Author | License | Modifiable? | Redistributable? | Attribution Required? |
|------------|--------|--------|---------|-------------|------------------|----------------------|
| `plugins/sasl/*.xpl`, `plugins/sasl/data/**` | 1-sim.com | SASL developers | Proprietary (free, non-commercial) | **NO** | NO | Yes |

**Evidence:** `plugins/sasl/License`

---

### 3.4 AT Plugin (Disabled)

| Asset Path | Source | Author | License | Modifiable? | Redistributable? | Attribution Required? |
|------------|--------|--------|---------|-------------|------------------|----------------------|
| `plugins/AT.disabled/**` | SASL | SASL developers | Proprietary | **NO** | NO | Yes |

**Evidence:** `plugins/AT.disabled/License SASL`, `plugins/AT.disabled/LICENSE`

---

### 3.5 Avionics Bay Plugin

| Asset Path | Source | Author | License | Modifiable? | Redistributable? | Attribution Required? |
|------------|--------|--------|---------|-------------|------------------|----------------------|
| `plugins/avionicsbay/*.so`, `*.dylib`, `*.dll` | HMW contributors | HMW contributors | Unknown (internal) | YES | YES | Yes (HMW contributors) |

**Evidence:** `plugins/avionicsbay/backups/libavionicsbay.arm64.original.dylib`

---

### 3.6 Fonts

| Asset Path | Source | Author | License | Modifiable? | Redistributable? | Attribution Required? |
|------------|--------|--------|---------|-------------|------------------|----------------------|
| `plugins/sasl/data/modules/Custom Module/fonts/B612-*` | SIL International | SIL | OFL 1.1 | YES | YES | No (OFL permits embedding) |
| `plugins/sasl/data/modules/Custom Module/fonts/SourceCodePro.ttf` | Adobe | Adobe | Apache 2.0 / OFL | YES | YES | No |
| `plugins/sasl/data/modules/Custom Module/textures/EFB/Icons/**` | HMW / various | HMW contributors | GPL v3 (project code) | YES | YES | Yes |

---

## 4. Licensing Compatibility Summary

| License Family | Assets | Compatible With GPL v3? | Redistribution Notes |
|----------------|--------|------------------------|---------------------|
| GPL v3 (HMW code) | Lua scripts, docs | YES | Permissive |
| GPL v2 (A321_Mod gear) | LandingGears.obj, textures | **NO** (v2 not compatible with v3) | Requires GPL v2 for combined distribution |
| CC BY-NC-ND 4.0 (Jonathan Orr objects) | Legacy objects | **NO** (ND = no derivatives) | Cannot modify; cannot combine with GPL |
| CC BY-NC-SA 4.0 (fmod sounds) | Sound banks | **NO** (SA + NC incompatible with GPL) | Share-alike required; non-commercial only |
| Proprietary (SASL, AT) | Plugin binaries | **NO** | Cannot redistribute |

**Blocking Issue:** The project combines CC BY-NC-ND 4.0 aircraft objects with GPL v2 landing gear and GPL v3 Lua code. These licenses are mutually incompatible for redistribution. The project **must remain private** until this is resolved.

---

## 5. Assets Requiring Legal Review

| Asset | Path | Concern |
|-------|------|---------|
| Landing gear + door geometry | `objects/LandingGears.obj`, `objects/LandingGears.png`, `objects/LandingGears_NRM.png` | GPL v2 combined with CC BY-NC-ND objects |
| Sound bank | `fmod/` | CC BY-NC-SA 4.0 combined with GPL v3 code |
| Plugin binaries | `plugins/sasl/`, `plugins/AT.disabled/` | Proprietary — cannot redistribute |
| Legacy aircraft objects | `objects/legacy/` | CC BY-NC-ND 4.0 — cannot modify |

---

## 6. Attribution Requirements (Mandatory if redistributed)

1. **Jonathan Orr** — Aircraft model (CC BY-NC-ND 4.0)
2. **Josh Davidson, Jonathan Redpath, merspieler, Matthew Maring, Thorsten Herrmann, Semir Gebran** — Landing gear assembly (GPL v2)
3. **A32NX contributors** — FMOD sound bank (CC BY-NC-SA 4.0)
4. **SASL developers (1-sim.com)** — SASL plugin framework (proprietary)
5. **SIL International** — B612 fonts (OFL 1.1)
6. **Adobe** — Source Code Pro font (Apache 2.0 / OFL)

---

## 7. Register Maintenance

This register must be updated when:
- New third-party assets are imported
- Asset sources or licenses change
- Assets are removed from the project
- Redistribution is considered

**Next review:** Before any push to a public repository or any redistribution outside private development.
