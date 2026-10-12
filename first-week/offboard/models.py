"""Data shapes shared by the planner, executor and CLI. No changes needed here."""

from __future__ import annotations

from dataclasses import dataclass, field
from datetime import date
from typing import Any


@dataclass(frozen=True)
class OffboardRequest:
    """An offboarding ticket, as it would arrive from the request queue."""

    ticket_id: str
    name: str
    email: str
    github_username: str | None
    role: str  # "employee" or "contractor"
    manager_email: str
    last_day: date
    systems: list[str]  # e.g. ["workspace", "github", "slack", "cloudflare", ...]

    @classmethod
    def from_dict(cls, d: dict[str, Any]) -> "OffboardRequest":
        return cls(
            ticket_id=d["ticket_id"],
            name=d["name"],
            email=d["email"],
            github_username=d.get("github_username"),
            role=d["role"],
            manager_email=d["manager_email"],
            last_day=date.fromisoformat(d["last_day"]),
            systems=list(d["systems"]),
        )


@dataclass(frozen=True)
class Action:
    """One step of an offboarding plan.

    system:    "workspace", "github", or any other system name for manual steps
    operation: what to do, e.g. "suspend_user", "remove_from_group", "manual"
    target:    what it applies to (an email, a group, a username...)
    automated: False for steps a human has to do (they go on the checklist)
    params:    any extra arguments the operation needs
    """

    system: str
    operation: str
    target: str
    automated: bool = True
    params: dict[str, Any] = field(default_factory=dict)


@dataclass(frozen=True)
class AuditEntry:
    """One line of the audit log.

    status is one of:
      "applied"      the change was made
      "would_apply"  dry-run, the change would be made
      "manual"       a human needs to do this
      "failed"       the change was attempted and errored
    """

    action: Action
    status: str
    detail: str = ""

    def __str__(self) -> str:
        a = self.action
        line = f"[{self.status:<11}] {a.system}:{a.operation} {a.target}"
        if a.params:
            line += " " + " ".join(f"{k}={v}" for k, v in a.params.items())
        return f"{line} ({self.detail})" if self.detail else line
