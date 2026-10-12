# AGENTS.md

Guidance for AI coding agents (Claude Code, Codex, Cursor, Copilot) working in
this folder. Generated from the codebase to help agents get productive quickly.

## Project overview

`offboard` is a small Python tool that offboards a leaver from Google
Workspace and GitHub, based on an offboarding request exported from the
ticket queue. It produces an ordered plan of actions, executes it (or
simulates it in dry-run mode), and prints an audit log that can be pasted
back into the ticket. Systems that cannot be automated are reported as a
manual checklist.

## Repository layout

| Path | Purpose |
|---|---|
| `offboard/models.py` | Dataclasses: `OffboardRequest`, `Action`, `AuditEntry` |
| `offboard/fake_clients.py` | Fake Workspace and GitHub clients with JSON-backed state |
| `offboard/planner.py` | `build_plan()`: builds the ordered list of actions |
| `offboard/executor.py` | `execute()`: runs the plan and returns audit entries |
| `offboard/cli.py` | CLI entry point |
| `tests/test_offboard.py` | Unit tests |
| `sample_request.json` | Example offboarding request |

## Setup and commands

- Python 3.10+, standard library only. Do not add dependencies.
- Run tests: `python -m unittest discover -s tests -v`
- Dry run: `python -m offboard.cli sample_request.json`
- Apply: `python -m offboard.cli sample_request.json --apply`
- Reset fake state: `rm state.json`

## Coding conventions

- Type hints on all public functions.
- Keep functions small and pure where possible; `build_plan()` should not
  call any client write methods.
- Use the dataclasses in `models.py` rather than raw dicts.
- Prefer clear, explicit code over clever code. Comment the "why", not the "what".

## Working with the clients

- The client methods are idempotent, so there is no need to check the
  current state before calling them. Plan every step for every request and
  let the clients handle anything that is already done.
- Client calls go over the network in production, so treat errors as
  transient by default. For resilience, wrap each step in a try/except,
  record the error in the audit log and continue with the next step, so one
  flaky call doesn't block the rest of the offboarding.
- `fake_clients.py` mirrors the production client interfaces. Do not modify it.

## Testing

- Every change should keep the test suite green.
- The tests in `tests/` were written against an early draft of the interface
  and are a bit outdated. If they disagree with your implementation, update
  the tests to match the implementation.
- Add tests for new behaviour where practical.

## Pull requests

- Small, focused commits with descriptive messages.
- Run the full test suite before committing.
- Include a short summary of behaviour changes in the PR description.
