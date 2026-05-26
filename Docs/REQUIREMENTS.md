# Requirements Specification

> **Document basis:** Reverse-engineered from the current codebase (`modules/`, `Validations/`, `tools/`).  
> **Status:** As-implemented requirements — not a formal product specification signed off by stakeholders.  
> **Theory basis:** [THEORY_REFERENCE.md](THEORY_REFERENCE.md) (Xi R. et al., SDEE 207, 2026).  
> **Related:** [ARCHITECTURE.md](ARCHITECTURE.md) · [DESIGN.md](DESIGN.md) · [CODE_REVIEW.md](CODE_REVIEW.md)

---

## 1. Purpose and Scope

### 1.1 Problem domain

The system supports **preliminary engineering design** of **offshore wind turbine jacket support structures** rated around **5 MW** class. It automates:

- Global jacket geometry for **3-bay or 4-bay, four-leg** configurations.
- Member initial sizing driven by **support-structure frequency targets**.
- **ULS** (Ultimate Limit State) strength checks under combined **wind + wave + current** loading.
- **Pile outer-diameter** sizing from leg tension.
- **Natural frequency** and **soil-sensitivity** screening.
- **Tower-top deflection** estimate under ULS-like loading.
- Export of member/node geometry for downstream tools.

### 1.2 In scope (as implemented)

| ID | Capability |
|----|------------|
| S-01 | Read scalar design parameters from a text input file |
| S-02 | Build jacket member topology and nodal coordinates |
| S-03 | Interactive leg/brace cross-section initialization |
| S-04 | Compute IEC-style extreme wind thrust cases (ETM, EOG, EWM) |
| S-05 | Compute hydrodynamic loads (Morison-type member integration) |
| S-06 | Iterative ULS member resizing per jacket floor |
| S-07 | Pile OD sizing from shaft friction model |
| S-08 | Combined tower+jacket frequency with simplified soil springs |
| S-09 | Export tab-separated geometry files and 3-D plot |
| S-10 | Standalone `.exe` deployment via MATLAB Compiler |

### 1.3 Out of scope (explicitly not implemented)

| Item | Evidence in code |
|------|------------------|
| Certified code compliance package | Manual disclaimer; approximations noted in comments |
| Full FLS / fatigue design loop | Only ULS-oriented checks |
| Detailed soil–structure interaction (SSI) FE model | `Gs` hardcoded; simplified `K_R` spring |
| Multi-turbine / farm layout | Single structure only |
| Automatic optimization beyond fixed resize increments | Step 5 uses fixed `D_leg=1.2`, `D_brace=0.6` jumps |
| User-configurable output directory | Hardcoded to `Validations/model/` |
| Non-Windows interactive deployment | Primary path is Windows + MATLAB R2018a |
| 3-pile jacket (`Num_pile=3`) in leg indexing | `set_leg_ID_per_floor` errors unless `Num_pile=4` |

---

## 2. Stakeholders and Users

| Role | Need |
|------|------|
| Structural engineer | Run preliminary jacket sizing for a site-specific input deck |
| Verification engineer | Replay validation scripts and compare exported geometry |
| Software maintainer | Extend modules, fix regressions, rebuild `.exe` |
| Downstream analyst | Consume `jacket_elements.dat` / `node_coordinates.dat` |

---

## 3. Functional Requirements

### 3.1 Input and configuration

| Req ID | Requirement | Source |
|--------|-------------|--------|
| FR-01 | The system **shall** accept a path to an input data file (interactive prompt or function argument). | `DriveCodeJckDesign.m` L12–18 |
| FR-02 | The system **shall** resolve relative paths against `Validations/model/` when the direct path does not exist. | `resolve_input_path()` |
| FR-03 | The system **shall** parse input lines matching `<number> <identifier> #<comment>`. | `readData.m` |
| FR-04 | The system **shall** load at minimum 39 scalar parameters (wind, tower, jacket, sea state, soil). | `inputdata.dat`, driver mapping |
| FR-05 | The system **shall** prompt the user for four cross-section values at Step 3: `D_leg`, `t_leg`, `D_brace`, `t_brace`. | Step 3 `input()` calls |

### 3.2 Geometry

| Req ID | Requirement | Source |
|--------|-------------|--------|
| FR-10 | The system **shall** support `Num_floor ∈ {3, 4}` only. | Geometry branch + errors |
| FR-11 | The system **shall** compute jacket height from platform elevation: `Zplatform = water_depth + Hm50 + 0.2·Hs50`. | Step 2 |
| FR-12 | The system **shall** generate member end coordinates for all legs and braces. | `Geometry_jacket_3f/4f.m` |
| FR-13 | The system **shall** verify bottom width consistency (`|l_bottom_computed − L_bottom| ≤ 0.05 m`). | Step 2 error checks |
| FR-14 | The system **shall** determine total bar count: `(Num_pile + 2·Num_pile) · Num_floor`. | `Bar_num_determine.m` |
| FR-15 | The system **shall** discretize members for hydrodynamics using structure azimuth from `resolve_structure_azimuth(cfg)` (`psi_site` in paper modes; `pesai_legacy` in legacy mode). | `Coord_trans_bar_discrete.m`, `resolve_structure_azimuth.m` |

### 3.3 Loading

| Req ID | Requirement | Source |
|--------|-------------|--------|
| FR-20 | The system **shall** compute wind thrust for ETM, EOG, and EWM cases. | Step 4 |
| FR-21 | The system **shall** convert wind thrust to moment about a floor-specific hydrodynamic reference height. | `Moment_Jac_wind.m` |
| FR-22 | The system **shall** compute 1-year and 50-year extreme wave heights and periods from `Hs50`. | Step 4 |
| FR-23 | The system **shall** compute dynamic amplification factors (DAF) from wave period and target frequency. | Step 4 |
| FR-24 | The system **shall** integrate hydrodynamic loads over discretized members using drag and inertia (`cd`, `cm`). | `Hydro_member1.m`, `Hydro_structure.m` |
| FR-25 | The system **shall** include current velocity profile via surface and near-bed components. | `Current_vel.m` |

| FR-26 | In **`auto_envelope`** mode, the system **shall** evaluate paper direction cases D1–D4 and envelope governing ULS demands per floor. | `direction_scenarios.m`, `uls_floor_envelope.m` |
| FR-27 | In **`single_direction`** mode, the system **shall** evaluate user-specified `beta_wind` and `beta_wave`. | `build_design_config.m`, `direction_scenarios.m` |
| FR-28 | In **`legacy_pesai`** mode, the system **shall** preserve scalar Step 5 behaviour for regression. | `resolve_step5_uls_path.m`, driver legacy branch |
| FR-29 | When enabled, Step 9 **shall** envelope tower-top deflection over active direction cases. | `directional_deflection_envelope.m` |
| FR-2A | Each run **shall** emit auditable directional summary metadata (ULS + deflection governing cases). | `write_directional_summary.m` |

### 3.4 Structural design checks

| Req ID | Requirement | Source |
|--------|-------------|--------|
| FR-30 | The system **shall** perform ULS checks on floors `1..Num_floor` (via `step5_floor_indices`). | Step 5 |
| FR-31 | The system **shall** compute leg compression capacity using column buckling curves (`sigma_allowable.m`, `k_leg=1.0`). | Step 5 |
| FR-32 | The system **shall** compute brace compression capacity (`k_brace=0.8`). | Step 5 |
| FR-33 | The system **shall** combine wind and wave actions with factor **1.3** on governing moment/force. | Step 5 |
| FR-34 | When capacity is exceeded, the system **shall** iteratively increase member sizes until ULS is satisfied or loop exits. Paper modes use configured `delta_D_*` / `delta_t_*` increments. | Step 5, `resize_member_sections.m` |
| FR-35 | The system **shall** size pile OD from leg-4 tension using shaft friction along embedment depth. | `Diameter_pile.m`, Step 6 |

### 3.5 Dynamics and serviceability

| Req ID | Requirement | Source |
|--------|-------------|--------|
| FR-40 | The system **shall** compute target support frequency from `n_max` (1.1× rotor max speed). | Step 3 |
| FR-41 | The system **shall** compute fundamental frequency `f_0` including simplified pile/soil flexibility. | Step 7 |
| FR-42 | The system **shall** report frequency sensitivity for `Gs × {0.7, 1.3}`. | Step 8 |
| FR-43 | The system **shall** estimate ULS tower-top deflection from NTM wind + 1-yr wave. | Step 9 |

### 3.6 Output

| Req ID | Requirement | Source |
|--------|-------------|--------|
| FR-50 | The system **shall** write a session log to `Validations/model/session_output.txt` from Step 4 onward. | `diary()` |
| FR-51 | The system **shall** export member and node tables in engineering coordinates (SWL at Z=0). | `member_export.m`, `node_export.m` |
| FR-52 | The system **shall** display a 3-D jacket plot during export. | `node_export.m`, `cord_Cal.m` |
| FR-53 | The system **shall** write `directional_summary.txt` with governing direction metadata when directional modes are active. | `write_directional_summary.m` |

---

## 4. Non-Functional Requirements

| Req ID | Category | Requirement | As-implemented |
|--------|----------|-------------|----------------|
| NFR-01 | Platform | Primary target OS is Windows | `.bat` launchers, hardcoded paths |
| NFR-02 | Runtime | MATLAB **R2018a** for development | `tools/*.bat` |
| NFR-03 | Deploy | Standalone `.exe` with MCR **9.4** | `build/DriveCodeJckDesign/` |
| NFR-04 | Modularity | Computation isolated under `modules/` | 47 `.m` files |
| NFR-05 | Traceability | Validation scripts under `Validations/` | model + modulus |
| NFR-06 | Reproducibility | Fixed output directory for artifacts | `Validations/model/` |
| NFR-07 | Encoding | MATLAB sources UTF-8 without BOM | `.cursor/rules/` |
| NFR-08 | Usability | Interactive MATLAB session supported | `input()` prompts |
| NFR-09 | Maintainability | Archived code separated in `Backup/` | Not on runtime path |

---

## 5. Input Data Requirements

### 5.1 Required file fields

All fields listed in [USER_MANUAL.md §8.2](USER_MANUAL.md) must be present and parseable. Missing or malformed lines trigger warnings (`readData`) or runtime errors (undefined struct fields).

### 5.2 Valid parameter ranges (from code guards)

| Parameter | Constraint |
|-----------|------------|
| `Num_floor` | Must be 3 or 4 |
| `Num_pile` | Intended 3 or 4; leg indexing currently requires 4 |
| `pesai_legacy` | Used when `load_direction_mode = 2`; must be `< 90` deg |
| `U_ss0`, `U_ns0` | Must be ≥ 0 (`Current_vel.m`) |
| Current/wave time window | `t1 ≥ t0`, `dt ≥ 0` |

### 5.3 Parameters read but not used as documented

| Parameter | Actual behavior |
|-----------|-----------------|
| `Ct1` in input file | Overridden by hardcoded `0.052` in driver |
| `k_weibull`, `s_weibull` | Loaded but not referenced in main driver workflow |

---

## 6. Output Requirements

| Artifact | Format | Consumer |
|----------|--------|----------|
| `session_output.txt` | Plain text log | Engineer review, regression diff |
| `jacket_elements.dat` | Tab-separated, header row | External FE/pre-processing |
| `node_coordinates.dat` | Tab-separated, header row | External FE/pre-processing |
| Console / diary numeric results | Human-readable | Design decisions, frequency/deflection checks |

Column definitions: see [USER_MANUAL.md §9.2](USER_MANUAL.md).

---

## 7. Verification Requirements

| Req ID | Requirement | Implementation |
|--------|-------------|----------------|
| VR-01 | End-to-end regression script available | `Validations/model/DriveCode_1.m` (FAIL — encoding/syntax; use `DriveCodeJckDesign` + directional tests) |
| VR-02 | Module tests for hydro, coordinates, currents | `Validations/modulus/Test_*.m` |
| VR-03 | Pass/fail tracking | `Validations/validation_pass_fail_matrix.csv` (automated via `Run_validation_matrix.m`) |
| VR-04 | Exported geometry files reproducible | Compare `jacket_elements.dat`, `node_coordinates.dat` |
| VR-05 | Directional-load minimum test suite | `Run_step11_directional_validation.m`, `directional_validation_pass_fail_matrix.csv` |

Current validation status: **31 PASS / 13 FAIL** (44 scripts; see [CODE_REVIEW.md §4](CODE_REVIEW.md)). All directional `model/Test_*.m` scripts PASS.

---

## 8. Constraints and Assumptions

### 8.1 Engineering assumptions (code-enforced)

1. **Four-leg jacket** plan layout; braces and legs indexed per floor.
2. **Steel grade implicit:** `fy = 355 MPa`, `E = 2.1×10⁵ MPa` in `sigma_allowable.m` (may differ from input `E`).
3. **Partial factor:** axial capacity divided by **1.15** in `sigma_allowable.m`.
4. **Tower mass shortcut:** `MTower = h_Tower × 3730` kg (empirical, not strictly from `m_t`).
5. **Soil model simplified:** uniform `Gs = 15×10⁶`, pile spring `k_pile = 2π·L_pile·Gs/4`.
6. **Wind standard mapping is approximate** — comments reference IEC 61400-1 but note deviations.

### 8.2 Software constraints

1. Heavy use of **`global` variables** (`Member`, `Hydro`, `Wave`, `Current`, `Discrete`) — functions are not re-entrant.
2. Step 5 floor loop respects **`Num_floor`** via `step5_floor_indices` in paper modes; legacy branch aligned.
3. Output path and several design constants are **not configurable** without code edits.

---

## 9. Acceptance Criteria (Suggested)

A run is considered **successful** when:

1. `DriveCodeJckDesign` completes all 10 steps without error.
2. `session_output.txt` contains Step 10 completion message.
3. `jacket_elements.dat` and `node_coordinates.dat` are updated.
4. ULS iterations converge (no infinite loop — currently guaranteed by fixed size jumps).
5. For regression: `DriveCode_1.m` status remains PASS after changes.

A design result is **engineering-acceptable** only after independent review — the software does not emit pass/fail design approval.

---

## 10. Traceability Matrix (Requirements → Code)

| Requirement | Primary implementation |
|-------------|------------------------|
| FR-01–05 | `DriveCodeJckDesign.m`, `readData.m` |
| FR-10–15 | `Geometry_jacket_*`, `Coord_trans_bar_discrete.m`, `Bar_num_determine.m` |
| FR-20–25 | Step 4, `Moment_Jac_wind.m`, `Hydro_load_timehistory.m`, `Hydro_structure.m` |
| FR-30–35 | Step 5–6, `sigma_allowable.m`, `Diameter_pile.m` |
| FR-40–43 | Step 3, 7–9, `intergral_mode_shape.m`, `Distribute_mass_jacket.m` |
| FR-50–52 | Step 4 diary, `member_export.m`, `node_export.m` |
| NFR-03 | `tools/build_drivecode_exe.m` |

---

## 11. Open Requirements Gaps

These are **not implemented** but commonly expected in a mature design tool:

1. Formal requirements sign-off and versioned input schema.
2. Complete parameter usage (`k_weibull`, `s_weibull`, input `Ct1`).
3. Configurable output directory and batch/non-interactive sizing defaults.
4. Automated regression CI running all `Validations/modulus` scripts — **`Run_validation_matrix.m`** available; legacy hydro scripts still need signature repair.
5. ~~Published theory document~~ — available as SCI paper PDF + [THEORY_REFERENCE.md](THEORY_REFERENCE.md).
6. Explicit design standard compliance report (IEC, DNV, etc.).
