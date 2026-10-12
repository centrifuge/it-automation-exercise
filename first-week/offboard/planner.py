"""Builds the offboarding plan. THIS IS YOURS TO WRITE."""

from __future__ import annotations

from datetime import date

from offboard.fake_clients import GitHubClient, WorkspaceClient
from offboard.models import Action, OffboardRequest


def build_plan(
    request: OffboardRequest,
    workspace: WorkspaceClient,
    github: GitHubClient,
    today: date,
) -> list[Action]:
    """Return the ordered list of actions needed to offboard `request`.

    Requirements:
    - Workspace and GitHub steps are automated (automated=True).
    - Every other system in request.systems becomes a manual step
      (automated=False) so it ends up on the human checklist.
    - Order matters. Think about what has to happen before what.
    - Only plan what still needs doing, given the current state of the
      clients. Planning against an already offboarded user should return
      only the manual steps.
    - Decide and document what happens if today is before request.last_day.
    """
    raise NotImplementedError
