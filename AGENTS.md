# Contributor Guide

This project is a Python 3.12 backend service built with FastMCP and httpx. All source code lives under `src/intervals_mcp_server` and tests live under `tests`.

## Development Environment
- Use [uv](https://github.com/astral-sh/uv) to create and manage the virtual environment.
  - `uv venv --python 3.12`
  - `source .venv/bin/activate`
- Sync dependencies including dev extras with `uv sync --all-extras`.
- When editing or running the server manually use `mcp run src/intervals_mcp_server/server.py`.

## Testing Instructions
- Run unit tests with `pytest` from the repository root.
- Ensure linting passes with `ruff .` (no configuration file means default rules).
- Run static type checks using `mypy src tests`.
- All three steps (`ruff`, `mypy`, and `pytest`) should succeed before committing.

## PR Instructions
- Use concise commit messages.
- Title pull requests using the format `[intervals-mcp-server] <brief description>`.
- Describe any manual testing steps performed and mention whether `pytest`, `ruff`, and `mypy` passed.

There is currently no frontend code in this repository. If a frontend is added in the future (for example with React or another framework), document how to run and test it within this file.

## Azure / Terraform Deployment

This repository is a **fork** — it is NOT a satellite of `lazinscy/org-standards`
and is not managed by `syncrepos`. When working on Azure deployment or
infrastructure for this project, use the org-standards documentation as a
reference but adapt patterns to fit this repo without breaking its fork
relationship with upstream.

### Where to find deployment guidelines

The `lazinscy/org-standards` repository contains authoritative docs on
Azure/Terraform deployment patterns used across the organization:

- `docs/infrastructure/terraform.md` — Terraform standards, per-repo
  structure (`terraform/` directory layout), state management (azurerm
  backend in shared Storage Account), CI/CD workflow patterns
  (terraform-plan on PR, deploy on release), two-phase Container Apps
  deploy, drift detection
- `docs/infrastructure/azure-agents.md` — Azure resource types, naming
  conventions, required tags, Container Apps debugging
- `docs/infrastructure/github-terraform.md` — GitHub org/repo settings
  managed by Terraform

For a working example of a deployed Python MCP server, see
`lazinscy/anki-mcp` — it has a complete `terraform/` directory and
`.github/workflows/deploy.yml`.

### Fork constraints — what to avoid

- Do NOT add org-standards satellite workflows (ruff.yml, pyright.yml,
  pytest.yml, coverage.yml, conventional-commits.yml, semantic-release.yml,
  markdownlint.yml, do-*.yml, auto-add-to-project.yml). This repo keeps
  its upstream CI workflows (`python-app.yml`, `pylint.yml`, `stale.yml`).
- Do NOT merge pyproject.toml fragments from org-standards — use the
  existing upstream pyproject.toml as-is.
- Do NOT add marker-based shared content (`<!-- org:shared -->` etc.) to
  README.md or create a CLAUDE.md with org markers.
- Do NOT modify `.pre-commit-config.yaml` to match org-standards hooks.
- Do NOT add org-standards issue/PR templates or `labels_exclusive` config.

### What IS allowed

- Adding a `terraform/` directory with Azure infrastructure (this is new
  code, does not conflict with upstream).
- Adding deployment workflows (`deploy.yml`, `terraform-plan.yml`) that
  are specific to this fork's Azure deployment.
- Adding `scripts/deploy.sh` as a local convenience wrapper.
- Modifying the `Dockerfile` minimally — e.g. changing CMD to support
  HTTP transport (`MCP_TRANSPORT` env var), adding `EXPOSE`.
- Following org-standards naming, tagging, and state management
  conventions in Terraform code.
- Using org-level OIDC secrets (`AZURE_CLIENT_ID`, `AZURE_TENANT_ID`,
  `AZURE_SUBSCRIPTION_ID`) which are available to all repos.

### Divergences from org-standards satellites

This section lists concrete differences between this fork and a typical
`lazinscy/org-standards` satellite. **Agents must keep this list up to date** —
when adding or removing a divergence, update the corresponding entry.

| Area | Satellite (org-standards) | This fork |
| --- | --- | --- |
| Sync | Registered in `syncrepos.yml`, auto-synced | NOT registered, no sync |
| CI — linting | `ruff.yml` (reusable workflow) | `pylint.yml` (upstream) |
| CI — tests | `pytest.yml` (reusable workflow) | `python-app.yml` (upstream) |
| CI — type check | `pyright.yml` (reusable workflow) | None (mypy used locally) |
| CI — coverage | `python-coverage.yml` (reusable workflow) | None |
| CI — commits | `conventional-commits.yml` | None (upstream conventions) |
| CI — markdown | `markdownlint.yml` | None |
| CI — release | `semantic-release.yml` + `merge-back.yml` | None (manual releases) |
| CI — agents | `do-dispatcher.yml`, `do-research.yml`, `do-plan.yml`, `do-accept.yml` | None |
| CI — project | `auto-add-to-project.yml` | None |
| Deploy | `deploy.yml` calling reusable pytest | `deploy.yml` with inline tests |
| Pre-commit | org-standards hooks (ruff, pyright, coverage, conventional-commits) | Upstream hooks (ruff, typos, no-commit-to-branch) |
| pyproject.toml | Fragments merged from org-standards | Upstream pyproject.toml as-is |
| Shared content | `<!-- org:shared -->` / `<!-- python:shared -->` markers in README, CLAUDE.md | No markers, no CLAUDE.md |
| Issue templates | org-standards templates (bug, feature, task, epic) | None |
| PR template | org-standards PR template | None |
| Labels | org-standards labels with `labels_exclusive: true` | Upstream labels |
| Dependabot | org-standards dependabot.yml | None |
| Branch model | `dev` branch + merge-back from `main` | `main` only |
