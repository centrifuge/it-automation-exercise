"""Fake Google Workspace and GitHub clients. No changes needed here.

They keep state in a JSON file (state.json by default) so that running the
CLI twice behaves like running it twice against the real APIs. Delete the
file to reset to the seeded state.

Like the real APIs, some calls raise NotFoundError when the thing you are
acting on does not exist (for example removing a user from a group they are
not in). Plan accordingly.
"""

from __future__ import annotations

import json
from pathlib import Path


class NotFoundError(Exception):
    pass


SEED_STATE = {
    "workspace": {
        "users": {
            "alex.doe@example-co.io": {
                "suspended": False,
                "groups": ["engineering@example-co.io", "all@example-co.io", "oncall@example-co.io"],
                "drive_files_owned": 42,
                "oauth_tokens": ["slack", "notion", "github"],
                "active_sessions": 3,
            },
            "maria.lead@example-co.io": {
                "suspended": False,
                "groups": ["engineering@example-co.io", "all@example-co.io"],
                "drive_files_owned": 310,
                "oauth_tokens": [],
                "active_sessions": 1,
            },
        }
    },
    "github": {"org": "example-co", "members": ["alexdoe-dev", "marialead"]},
}


class _StateStore:
    def __init__(self, path: str | Path = "state.json"):
        self.path = Path(path)
        if self.path.exists():
            self.data = json.loads(self.path.read_text())
        else:
            self.data = json.loads(json.dumps(SEED_STATE))
            self.save()

    def save(self) -> None:
        self.path.write_text(json.dumps(self.data, indent=2))


class WorkspaceClient:
    """Fake Google Workspace Admin/Drive client."""

    def __init__(self, store: _StateStore):
        self._store = store
        self.calls: list[tuple] = []  # every mutating call, for tests

    @property
    def _users(self) -> dict:
        return self._store.data["workspace"]["users"]

    def _user(self, email: str) -> dict:
        if email not in self._users:
            raise NotFoundError(f"user {email} not found")
        return self._users[email]

    # ---- reads -------------------------------------------------------
    def get_user(self, email: str) -> dict:
        """Returns a copy of the user record. Raises NotFoundError."""
        return dict(self._user(email))

    # ---- writes ------------------------------------------------------
    def sign_out(self, email: str) -> None:
        """Ends all active web and mobile sessions."""
        self.calls.append(("sign_out", email))
        self._user(email)["active_sessions"] = 0
        self._store.save()

    def revoke_oauth_token(self, email: str, client: str) -> None:
        self.calls.append(("revoke_oauth_token", email, client))
        tokens = self._user(email)["oauth_tokens"]
        if client not in tokens:
            raise NotFoundError(f"token {client} not found for {email}")
        tokens.remove(client)
        self._store.save()

    def remove_from_group(self, email: str, group: str) -> None:
        self.calls.append(("remove_from_group", email, group))
        groups = self._user(email)["groups"]
        if group not in groups:
            raise NotFoundError(f"{email} is not a member of {group}")
        groups.remove(group)
        self._store.save()

    def transfer_drive(self, from_email: str, to_email: str) -> int:
        """Moves ownership of all Drive files. Returns the number moved."""
        self.calls.append(("transfer_drive", from_email, to_email))
        src, dst = self._user(from_email), self._user(to_email)
        moved = src["drive_files_owned"]
        dst["drive_files_owned"] += moved
        src["drive_files_owned"] = 0
        self._store.save()
        return moved

    def suspend_user(self, email: str) -> None:
        self.calls.append(("suspend_user", email))
        self._user(email)["suspended"] = True
        self._store.save()


class GitHubClient:
    """Fake GitHub org client."""

    def __init__(self, store: _StateStore):
        self._store = store
        self.calls: list[tuple] = []

    def is_member(self, username: str) -> bool:
        return username in self._store.data["github"]["members"]

    def remove_member(self, username: str) -> None:
        self.calls.append(("remove_member", username))
        members = self._store.data["github"]["members"]
        if username not in members:
            raise NotFoundError(f"{username} is not an org member")
        members.remove(username)
        self._store.save()


def make_clients(state_path: str | Path = "state.json") -> tuple[WorkspaceClient, GitHubClient]:
    store = _StateStore(state_path)
    return WorkspaceClient(store), GitHubClient(store)
