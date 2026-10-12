"""Acceptance tests. Make these pass, and add your own if useful.

    python -m unittest discover -s tests -v
"""

import tempfile
import unittest
from datetime import date
from pathlib import Path

from offboard.executor import execute
from offboard.fake_clients import make_clients
from offboard.models import OffboardRequest
from offboard.planner import build_plan

REQUEST = OffboardRequest(
    ticket_id="REQ-142",
    name="Alex Doe",
    email="alex.doe@example-co.io",
    github_username="alexdoe-dev",
    role="contractor",
    manager_email="maria.lead@example-co.io",
    last_day=date(2026, 10, 16),
    systems=["workspace", "github", "slack", "cloudflare", "claude", "1password", "yubikey"],
)
LAST_DAY = date(2026, 10, 16)


class FakeClientsWork(unittest.TestCase):
    """Sanity check of the provided fakes. Passes before you write anything."""

    def test_seeded_state(self):
        with tempfile.TemporaryDirectory() as d:
            ws, gh = make_clients(Path(d) / "state.json")
            self.assertFalse(ws.get_user(REQUEST.email)["suspended"])
            self.assertTrue(gh.is_member("alexdoe-dev"))


class Offboarding(unittest.TestCase):
    def setUp(self):
        self._dir = tempfile.TemporaryDirectory()
        self.state = Path(self._dir.name) / "state.json"
        self.ws, self.gh = make_clients(self.state)

    def tearDown(self):
        self._dir.cleanup()

    def run_once(self, apply):
        plan = build_plan(REQUEST, self.ws, self.gh, LAST_DAY)
        return execute(plan, self.ws, self.gh, apply=apply)

    def test_dry_run_changes_nothing(self):
        entries = self.run_once(apply=False)
        self.assertEqual(self.ws.calls, [])
        self.assertEqual(self.gh.calls, [])
        self.assertTrue(any(e.status == "would_apply" for e in entries))

    def test_apply_offboards(self):
        self.run_once(apply=True)
        user = self.ws.get_user(REQUEST.email)
        self.assertTrue(user["suspended"])
        self.assertEqual(user["groups"], [])
        self.assertEqual(user["oauth_tokens"], [])
        self.assertEqual(user["drive_files_owned"], 0)
        self.assertFalse(self.gh.is_member("alexdoe-dev"))

    def test_second_run_is_a_no_op(self):
        self.run_once(apply=True)
        ws2, gh2 = make_clients(self.state)  # fresh clients, same state
        plan = build_plan(REQUEST, ws2, gh2, LAST_DAY)
        entries = execute(plan, ws2, gh2, apply=True)
        self.assertEqual(ws2.calls, [])
        self.assertEqual(gh2.calls, [])
        self.assertTrue(all(e.status == "manual" for e in entries))

    def test_manual_checklist(self):
        entries = self.run_once(apply=False)
        manual = {e.action.system for e in entries if e.status == "manual"}
        self.assertEqual(manual, {"slack", "cloudflare", "claude", "1password", "yubikey"})


if __name__ == "__main__":
    unittest.main()
