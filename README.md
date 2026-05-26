# Jacket Design 5MW

Offshore wind **jacket support structure preliminary design** toolkit (MATLAB).

**Theory basis:** Implements the method in Xi R. et al. (2026), *Soil Dynamics and Earthquake Engineering* 207, 110344 — see [Docs/THEORY_REFERENCE.md](Docs/THEORY_REFERENCE.md).

## Branches

| Branch / tag | Purpose |
|--------------|---------|
| **`main`** | Current development baseline — directional-load workflow (PLAN Steps 1–12 complete), active maintenance |
| **`v2.0-directional-uls`** | Annotated release tag — directional ULS workflow (PLAN Steps 1–12) on `main` |
| **`legacy-early`** | Archived early implementation preserved for regression and historical comparison |
| **`legacy-v1`** | Tag pointing to the same commit as `legacy-early` |

Use **`main`** for normal clone, run, and contribution. Switch to `legacy-early` only when reproducing or comparing against the original project version:

```bash
git clone https://github.com/xirenqiang/Design-of-jacket-for-OWTs.git
cd Design-of-jacket-for-OWTs
# default checkout is main

git fetch origin legacy-early
git checkout legacy-early   # early archived version
git checkout main           # return to current development line
```

## Quick start

| Goal | Command / file |
|------|----------------|
| Run in MATLAB | `run('run_DriveCodeJckDesign.m')` from the repository root |
| One-click Windows launch | `tools\run_drivecode_matlab.bat` |
| Build standalone `.exe` | `tools\build_drivecode_exe.bat` |
| Sample input | `Validations\model\inputdata.dat` |
| Main outputs | `Validations\model\` (`session_output.txt`, `jacket_elements.dat`, `node_coordinates.dat`) |

**Main entry:** `modules/DriveCodeJckDesign.m`

**Documentation:** [Docs/README.md](Docs/README.md) (index)

| Doc | Description |
|-----|-------------|
| [USER_MANUAL.md](Docs/USER_MANUAL.md) | Usage, I/O, run & build |
| [REQUIREMENTS.md](Docs/REQUIREMENTS.md) | Requirements (from code) |
| [ARCHITECTURE.md](Docs/ARCHITECTURE.md) | System architecture |
| [DESIGN.md](Docs/DESIGN.md) | Detailed design |
| [THEORY_REFERENCE.md](Docs/THEORY_REFERENCE.md) | SCI paper ↔ code mapping |
| [CODE_REVIEW.md](Docs/CODE_REVIEW.md) | Code audit & remediation |

## Requirements

- Windows (primary development platform)
- MATLAB **R2018a** for interactive runs and building the executable
- MATLAB Compiler license (build only)
- MATLAB Runtime **9.4** (R2018a) on machines that run the compiled `.exe` without MATLAB

## Repository layout

```
jacket_design_5MW/
├── run_DriveCodeJckDesign.m   # Root launcher
├── modules/                   # Runtime computation core
├── Validations/
│   ├── model/                 # End-to-end validation + I/O artifacts
│   └── modulus/               # Module-level tests
├── tools/                     # Launch, build, and maintenance scripts
├── build/DriveCodeJckDesign/  # Compiled executable output
├── Docs/                      # User manual
└── Backup/                    # Archived scripts (not used at runtime)
```

## Disclaimer

This software supports engineering design study and verification workflows. It is **not** a certified design approval package by itself.
