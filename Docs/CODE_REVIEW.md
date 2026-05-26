# Code Review and Audit Report

> **Document basis:** Static review of source code, validation matrix, and cross-script consistency.  
> **Review date:** 2026-05-26 (validation matrix refresh)  
> **Scope:** `modules/`, `Validations/`, `tools/`, build artifacts  
> **Related:** [REQUIREMENTS.md](REQUIREMENTS.md) · [ARCHITECTURE.md](ARCHITECTURE.md) · [DESIGN.md](DESIGN.md)

---

## 1. Executive Summary

| Aspect | Assessment |
|--------|------------|
| **Overall** | Functional preliminary design pipeline with clear 10-step workflow |
| **Strengths** | Modular hydro/geometry functions; documented export formats; validation harness exists |
| **Weaknesses** | Global state, hardcoded constants (`Gs`, `Ct1`), legacy validation drift (13/44 FAIL) |
| **Production readiness** | Suitable for **engineering study** — directional ULS implemented; legacy hydro regression scripts need repair |

---

## 2. Review Methodology

1. Read primary driver `DriveCodeJckDesign.m` end-to-end.
2. Map module dependencies and global state usage.
3. Compare active driver vs. `Validations/model/DriveCode_1.m`.
4. Analyze `Validations/validation_pass_fail_matrix.csv`.
5. Inspect build/deploy chain and encoding/tooling scripts.
6. Classify findings by severity: **Critical / Major / Minor / Info**.

---

## 3. Findings by Severity

### 3.1 Critical

| ID | Finding | Location | Impact | Recommendation |
|----|---------|----------|--------|----------------|
| C-01 | **ULS resize assigns fixed absolute sizes** in **`legacy_pesai`** branch only | `DriveCodeJckDesign.m` legacy Step 5 | Paper modes use incremental `resize_member_sections` | **Partially resolved** — verify legacy branch if still needed |
| C-02 | **`Ct1` in input file ignored**; hardcoded `0.052` used for EWM | L213–215 | Input deck does not control EWM thrust | Read from `dataStruct.Ct1` or remove from input schema |
| C-03 | **`Num_pile=3` rejected** by `set_leg_ID_per_floor` despite `Bar_num_determine` allowing 3 | `set_leg_ID_per_floor.m` L17–19 | 3-pile configuration cannot run | Align validation across modules or document 4-pile only |

### 3.2 Major

| ID | Finding | Location | Impact | Recommendation |
|----|---------|----------|--------|----------------|
| M-01 | **Geometry formula divergence** between driver and validation: driver uses `L_bottom = L_top + √2·h·tan(av)`; `DriveCode_1.m` uses `L_top + 2·h·tan(av)` | Driver L94 vs `DriveCode_1.m` L57 | Regression script does not validate current production logic | Update `DriveCode_1.m` or split shared geometry function |
| M-02 | **Step 5 floor loop** | `step5_floor_indices` | **Resolved** in paper modes; legacy branch uses same helper |
| M-03 | **Heavy global state** — 47 functions depend on implicit `Member`, `Wave`, etc. | Throughout `modules/` | Untestable in isolation; order-dependent | Introduce context struct; reduce globals |
| M-04 | **13 of 44 validation scripts FAIL** | `validation_pass_fail_matrix.csv` | Legacy hydro API drift; encoding-damaged scripts | **`Run_validation_matrix.m` automated**; repair or quarantine failing legacy scripts |
| M-05 | **`sigma_allowable` uses fixed E=210 GPa** while input allows `E=2.1e11` — potential inconsistency if E changed | `sigma_allowable.m` L5 | Capacity error if material E differs | Pass `E` as parameter |
| M-06 | **`DriveCode_250401.m` FAIL** — hardcoded path to obsolete project | Validation matrix | Misleading if used as regression | Archive or fix paths |
| M-07 | **`pesai` input** — paper modes use `psi_site`/`beta_*`; legacy uses `pesai_legacy` from input | `build_design_config.m` | **Resolved** for paper modes; legacy regression isolated |
| M-08 | **`Gs=15e6` hardcoded** — soil stiffness not from input | Driver L545 | Frequency results not site-configurable | Add `Gs` to input or derive from soil params |

### 3.3 Minor

| ID | Finding | Location | Impact | Recommendation |
|----|---------|----------|--------|----------------|
| m-01 | `k_weibull`, `s_weibull` loaded but unused in driver | Step 1 | Dead input fields | Use or remove from schema |
| m-02 | Mixed Chinese/English comments; some `.m` files have encoding-corrupted headers | e.g. `Hydro_load_timehistory.m` | Maintainer readability | Normalize UTF-8; run sanitize script |
| m-03 | `.asv` autosave files in `modules/` | `*.asv` | Clutter; accidental confusion | Add to `.gitignore`; delete |
| m-04 | `debug` global never set by driver | Various modules | Validation branches inactive in production runs | Set `debug=0` explicitly or remove dead branches |
| m-05 | Step 9 loop index | Step 9 modules | **Improved** — `directional_deflection_envelope` decoupled from Step 5 loop variable |
| m-06 | `readData` error message incomplete | `readData.m` L9 | `'Input file not found: %s'` missing text | Fix error format string |
| m-07 | Empirical `MTower = h_Tower*3730` vs input `m_t` | Driver L76 | Inconsistent weight in ULS | Derive from `m_t` or document assumption |

### 3.4 Informational

| ID | Finding | Notes |
|----|---------|-------|
| I-01 | IEC 61400-1 mappings annotated "verify if needed" | Expected for preliminary tool |
| I-02 | Theory documented via SCI paper PDF + THEORY_REFERENCE.md | — |
| I-03 | `tools/check_toolchain*` references external VS/Fortran projects | Not part of jacket runtime |
| I-04 | `Backup/` contains superseded implementations | Correctly excluded from runtime |
| I-05 | Driver ~630 lines — high cyclomatic complexity in Step 5 | Refactor candidate |

---

## 4. Validation Audit

### 4.1 Summary (`validation_pass_fail_matrix.csv`)

| Status | Count |
|--------|-------|
| PASS | 31 |
| FAIL | 13 |
| **Total** | **44** |

Regenerate: `addpath('Validations'); Run_validation_matrix;`  
Log: `Validations/model/test_step12_validation_matrix_log.txt`

Directional suite (separate matrix): `Validations/directional_validation_pass_fail_matrix.csv` — all minimum Step 11 tests PASS.

### 4.2 Integrated tests (`Validations/model`)

| Script | Status | Root cause |
|--------|--------|------------|
| `DriveCode_1.m` | FAIL | Encoding/syntax (`m_unterminated_string`); geometry formulas differ from current driver (M-01) |
| `DriveCode_250401.m` | FAIL | Encoding/syntax; obsolete external path reference |

### 4.3 Module tests (`Validations/modulus`)

| Category | PASS | FAIL |
|----------|------|------|
| Coordinate / current / velocity | 4 | 1 (`Test_y_coordinate.m` — undefined `Member`) |
| Mode shape | 1 | 0 |
| Member hydro series | 14 | 8 |

**Common hydro test failures:** "too many input arguments" / "too many output arguments" — indicates **function signatures changed** since tests were written.

### 4.4 Recommended validation actions

1. **Priority 1:** Fix `DriveCode_1.m` to call `DriveCodeJckDesign` or shared step functions — single source of truth.
2. **Priority 2:** Update failing `Test_Member_Hydro_*` call signatures to match `Hydro_member1.m`.
3. **Priority 3:** ~~Automate validation matrix generation~~ — **`Run_validation_matrix.m`** (Step 12).
4. **Priority 4:** Remove or quarantine FAIL scripts that are obsolete.

---

## 5. Security and Deployment Review

| Topic | Status | Notes |
|-------|--------|-------|
| Secrets in repo | OK | No credentials found |
| Path injection | Low risk | Input path passed to `fopen` — use trusted paths only |
| Write access | Writes to `Validations/model/` only | Predictable |
| EXE rebuild | User confirmed 2026-05-21 rebuild | Timestamp aligns with source |
| MCR version lock | R2018a / 9.4 | Document clearly for deploy |

---

## 6. Code Quality Metrics (Qualitative)

| Metric | Rating | Comment |
|--------|--------|---------|
| Modularity | Medium | Good module split; poor driver coupling |
| Cohesion | Medium | Hydro cluster cohesive; ULS logic embedded in driver |
| Coupling | High | Globals + inline formulas |
| Testability | Medium | Directional modules have dedicated tests; globals remain in legacy path |
| Documentation | Good | SCI paper linked; PLAN Steps 1–12 complete; user docs updated |
| Maintainability | Medium | Clear step labels help navigation |

---

## 7. Standards and Compliance Gap Analysis

| Standard / topic | Referenced in code | Implemented faithfully? |
|--------------------|-------------------|-------------------------|
| IEC 61400-1 wind cases | Comments in Step 4 | **Partial** — EOG formulation noted as conservative deviation |
| Morison equation | Hydro modules | **Yes** (drag + inertia) |
| DNV / ISO offshore steel | Not referenced | Column curve appears simplified (fy=355, α=1.15) |
| DNV-RP-C205 hydrodynamics | Not referenced | Custom implementation |
| Geotechnical (piles) | `Diameter_pile.m` | **Simplified** 1-D friction integration |

**Conclusion:** No automatic compliance statement should be issued. Independent structural review required.

---

## 8. Remediation Roadmap

### Phase 1 — Correctness (1–2 weeks)

- [x] Fix C-01 resize logic (incremental D/t) — paper modes via `resize_member_sections.m`
- [ ] Fix C-02 read `Ct1` from input
- [x] Resolve M-02 floor loop — `step5_floor_indices`
- [ ] Align M-01 `DriveCode_1.m` with production geometry

### Phase 2 — Test hygiene (1–2 weeks)

- [ ] Repair failing legacy hydro tests (signatures)
- [ ] Fix `Test_y_coordinate.m` setup (initialize `Member`)
- [x] Automate validation matrix generation — `Run_validation_matrix.m`

### Phase 3 — Architecture (ongoing)

- [ ] Extract Step 5 ULS into `uls_floor_check.m`
- [ ] Replace globals with `model` struct
- [ ] Externalize hardcoded constants to config

### Phase 4 — Documentation (ongoing)

- [x] Link SCI theory paper and paper-to-code mapping ([THEORY_REFERENCE.md](THEORY_REFERENCE.md))
- [ ] Add design approval checklist template

---

## 9. Review Sign-Off Template

| Role | Name | Date | Notes |
|------|------|------|-------|
| Code reviewer | | | |
| Structural lead | | | |
| Software maintainer | | | |

---

## 10. Document History

| Date | Reviewer | Change |
|------|----------|--------|
| 2026-05-26 | Step 12 audit | Validation matrix 31/44 PASS; directional docs; M-02/M-07/C-01 partial fixes noted |
| 2026-05-21 | Code-derived audit | Initial audit document from codebase analysis |
