# HMW A321neo -- Asset Cleanup Report

**Project Directory:** `/Users/lukas/X-Plane 12/Aircraft/HMW_A321Neo_AppleSilicon_Dev/`
**Assessment Date:** 2026-10-21
**Status:** No assets deleted during this session. Report identifies candidates for future review.

---

## 1. Cleanup Actions Performed

| Action | Files/Geometry | Evidence | Status |
|--------|---------------|----------|--------|
| None | N/A | No deletions performed | Complete |

**No files were deleted** during this development session. All existing assets were preserved per the safety rules.

---

## 2. Candidate Assets for Future Cleanup

The following assets were identified as potentially unused or obsolete. **None were deleted** -- dependency verification is incomplete.

| Asset Path | Suspected Status | Evidence | Dependency Check Required? | Recommended Action |
|------------|-----------------|----------|---------------------------|-------------------|
| `objects/legacy/deactivated/front gear.obj` | Unused (in deactivated folder) | Referenced in `.acf` line 19207 was replaced by `LandingGears.obj`; file is in `deactivated/` subfolder | YES | Verify no Lua code references this path before deletion |
| `objects/left engine external.obj.bak` | Backup file | `.bak` extension suggests backup | YES | Verify not referenced before deletion |
| `objects/legacy/texture/front_gears_baked.png` + `.nml` | Possibly unused | Texture for old nose gear which is now in LandingGears.obj | YES | Verify no OBJ references this texture |
| `A321_prefs.txt` | Generated config | X-Plane preferences file | NO | Leave -- simulator-generated |
| `avionics-bay-internal.log` | Generated log | Log file | NO | Leave -- simulator-generated |
| `plugins/sasl/data/output/SASLLog.txt` | Generated log | Plugin output log | NO | Leave -- simulator-generated |
| `plugins/sasl/data/output/.gitignore` | Git config | Git ignore for output dir | NO | Leave -- git config |
| `plugins/sasl/data/.gitignore` | Git config | Git ignore for data dir | NO | Leave -- git config |
| `plugins/sasl/data/modules/configuration/.gitignore` | Git config | Git ignore for config dir | NO | Leave -- git config |
| `plugins/sasl/data/components/.gitignore` | Git config | Git ignore for components dir | NO | Leave -- git config |
| `plugins/sasl/data/modules/Custom Module/saved_configs/.gitignore` | Git config | Git ignore for saved_configs dir | NO | Leave -- git config |
| `plugins/sasl/data/modules/Custom Module/saved_configs/saved_view` | Generated | Saved view state | NO | Leave -- runtime state |
| `plugins/sasl/data/modules/Custom Module/tests/README` | Test documentation | Test suite README | NO | Leave -- part of test suite |
| `plugins/sasl/data/modules/Custom Module/textures/EFB/Icons/HOME page/overlay.png` | Possibly unused | EFB icons were removed from home page | YES | Verify no other EFB page references this |

---

## 3. Assets Verified In-Use

| Asset Path | Evidence |
|------------|----------|
| `objects/LandingGears.obj` | Referenced in `A321.acf` line 19207 (`_obja/46/_v10_att_file_stl LandingGears.obj`) |
| `objects/LandingGears.png` | Referenced in `objects/LandingGears.obj` `TEXTURE` directive |
| `objects/LandingGears_NRM.png` | Referenced in `objects/LandingGears.obj` `TEXTURE_NORMAL` directive |
| `objects/legacy/under carriage.obj` | Referenced in `A321.acf` line 19168 (`_obja/43`) |
| `objects/legacy/wing.obj` | Referenced in `A321.acf` line 19181 (`_obja/44`) |
| `objects/legacy/door.obj` | Referenced in `A321.acf` line 19194 (`_obja/40`) |
| `objects/legacy/fuselage.obj` | Referenced in `A321.acf` line 19142 (`_obja/41`) |
| `objects/legacy/h stabs.obj` | Referenced in `A321.acf` line 19155 (`_obja/42`) |
| `objects/legacy/cargo.obj` | Referenced in `A321.acf` line 19129 (`_obja/39`) |
| `objects/legacy/economy.obj` | Referenced in `A321.acf` line 19090 (`_obja/38`) |
| `objects/legacy/business class.obj` | Referenced in `A321.acf` line 19046 (`_obja/34`) |
| `objects/legacy/cabin dividers.obj` | Referenced in `A321.acf` line 19064 (`_obja/35`) |
| `objects/legacy/cabin exteriors.obj` | Referenced in `A321.acf` line 19077 (`_obja/36`) |
| `objects/legacy/cabin roof and window frames.obj` | Referenced in `A321.acf` line 19090 (`_obja/37`) |
| `objects/legacy/fuse misc items.obj` | Referenced in `A321.acf` line 19194 (`_obja/45`) |
| `objects/cockpit_obj/*.obj` (10 files) | Referenced in `A321.acf` lines 18670-19272 |
| `objects/cockpit_interior_obj/*.obj` (12 files) | Referenced in `A321.acf` lines 18820-19011 |
| All 47 objects in `.acf` | Each has `_v10_att_file_stl` reference |

---

## 4. Duplicate Assets Identified

| Asset | Possible Duplicate | Status |
|-------|-------------------|--------|
| `fmod/Master Bank.bank` (root fmod/) | `fmod/fmod/Master Bank.bank` | Both exist -- one may be symlink or duplicate |
| `fmod/Master Bank.strings.bank` (root fmod/) | `fmod/fmod/Master Bank.strings.bank` | Both exist -- one may be symlink or duplicate |
| `A321.snd` (root fmod/) | `fmod/A321BACKUP.snd` | Backup file |

**Note:** These duplicates were NOT investigated further. They may be required by the FMOD sound system.

---

## 5. Assets Left in Place (Reason)

| Asset Path | Reason Not Deleted |
|------------|-------------------|
| `objects/legacy/deactivated/front gear.obj` | In deactivated folder; may be needed for reference or fallback |
| `objects/left engine external.obj.bak` | Backup of external engine OBJ; may be needed if merge causes issues |
| `plugins/AT.disabled/` | Disabled plugin; kept for reference |
| `objects/LICENSE` | Jonathan Orr license -- legally required to preserve |
| `plugins/sasl/License` | SASL license -- legally required to preserve |
| `plugins/AT.disabled/License SASL` | AT license -- legally required to preserve |
| `plugins/AT.disabled/LICENSE` | AT license -- legally required to preserve |
| `fmod/LICENSE` | FMOD license -- legally required to preserve |

---

## 6. Cleanup Blockers

| Blocker | Detail |
|---------|--------|
| No Lua interpreter available | Cannot programmatically verify includes/requires |
| X-Plane 12 not accessible | Cannot test if deleting unused assets breaks simulator |
| `.acf` object references | 47 objects referenced by line number; moving/deleting any requires .acf edit |
| OBJ texture references | OBJ files reference textures with relative paths; moving textures breaks OBJs |
| License incompatibility | CC BY-NC-ND + GPL v2 + GPL v3 cannot be combined for redistribution |

---

## 7. Recommended Next Steps (When Approved)

1. Verify `objects/legacy/deactivated/front gear.obj` is not referenced by any Lua code before deletion
2. Verify `objects/left engine external.obj.bak` is not needed as fallback
3. Investigate `fmod/` duplicate `.bank` files
4. Create `tests/` directory if automated tests are to be added
5. Resolve licensing before any redistribution

---

## 8. Deletion Log

| Date | Asset | Reason | Approved By |
|------|-------|--------|-------------|
| None | N/A | No deletions performed | N/A |
