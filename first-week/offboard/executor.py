"""Runs an offboarding plan. THIS IS YOURS TO WRITE."""

from __future__ import annotations

from offboard.fake_clients import GitHubClient, WorkspaceClient
from offboard.models import Action, AuditEntry


def execute(
    plan: list[Action],
    workspace: WorkspaceClient,
    github: GitHubClient,
    apply: bool,
) -> list[AuditEntry]:
    """Run each action in `plan` and return one AuditEntry per action.

    Requirements:
    - apply=False is a dry run: no client write methods may be called.
    - apply=True calls the matching client methods.
    - Manual actions are never executed, only reported.
    - Decide and document what happens when one step fails.
    """
    raise NotImplementedError
