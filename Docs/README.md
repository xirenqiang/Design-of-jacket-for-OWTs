# Documentation Index

Offshore wind jacket preliminary design — project documentation set.

## Document map

| Document | Audience | Purpose |
|----------|----------|---------|
| [USER_MANUAL.md](USER_MANUAL.md) | End user | Installation, run instructions, I/O reference, FAQ |
| [REQUIREMENTS.md](REQUIREMENTS.md) | PM / engineer / QA | Functional & non-functional requirements (code-derived) |
| [ARCHITECTURE.md](ARCHITECTURE.md) | Developer | System layers, globals, module map, deployment |
| [DESIGN.md](DESIGN.md) | Developer / engineer | Step-by-step algorithms, formulas, API contracts |
| [THEORY_REFERENCE.md](THEORY_REFERENCE.md) | Engineer / researcher | SCI paper citation, equation mapping, standards |
| [PLAN_DIRECTIONAL_LOADS.md](PLAN_DIRECTIONAL_LOADS.md) | Maintainer | Approved hybrid plan for §2.5 directional ULS (not yet implemented) |

## Theory basis (SCI paper)

This project implements the method in:

> **A preliminary design method for jacket support structures of high-capacity offshore wind turbines**  
> Xi R. et al., *Soil Dynamics and Earthquake Engineering* 207 (2026) 110344  
> [DOI 10.1016/j.soildyn.2026.110344](https://doi.org/10.1016/j.soildyn.2026.110344)

| Resource | Path |
|----------|------|
| Paper PDF | [`A preliminary design method for jacket support structures of high-capacity offshore wind turbines.pdf`](A%20preliminary%20design%20method%20for%20jacket%20support%20structures%20of%20high-capacity%20offshore%20wind%20turbines.pdf) |
| Paper ↔ code map | [THEORY_REFERENCE.md](THEORY_REFERENCE.md) |

## Reading order

**New user:** USER_MANUAL → sample run with `inputdata.dat`

**New developer:** ARCHITECTURE → DESIGN → CODE_REVIEW

**Design review meeting:** REQUIREMENTS → [THEORY_REFERENCE.md](THEORY_REFERENCE.md) → [PLAN_DIRECTIONAL_LOADS.md](PLAN_DIRECTIONAL_LOADS.md) → DESIGN → CODE_REVIEW §7 (standards gaps)

## Source of truth

| Topic | Authoritative location |
|-------|------------------------|
| Runtime behavior | `modules/DriveCodeJckDesign.m` |
| Input schema | `Validations/model/inputdata.dat` + `modules/readData.m` |
| Validation status | `Validations/validation_pass_fail_matrix.csv` |
| Build output | `build/DriveCodeJckDesign/DriveCodeJckDesign.exe` |

## Maintenance

When changing the driver or module APIs:

1. Update [DESIGN.md](DESIGN.md) if algorithms or formulas change.
2. Update [THEORY_REFERENCE.md](THEORY_REFERENCE.md) if implementation deviates from or aligns further with the paper.
3. Update [REQUIREMENTS.md](REQUIREMENTS.md) if capabilities or constraints change.
4. Update [PLAN_DIRECTIONAL_LOADS.md](PLAN_DIRECTIONAL_LOADS.md) when directional-load scope or modes change.
5. Update [CODE_REVIEW.md](CODE_REVIEW.md) when findings are resolved.
6. Re-run validation scripts and update the pass/fail matrix.
7. Rebuild `.exe` if deploying compiled builds.
