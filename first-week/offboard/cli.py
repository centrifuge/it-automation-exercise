"""Command line entry point. No changes needed here.

    python -m offboard.cli sample_request.json            # dry run
    python -m offboard.cli sample_request.json --apply    # make changes
    rm state.json                                         # reset fake state
"""

from __future__ import annotations

import argparse
import json
import sys
from datetime import date

from offboard.executor import execute
from offboard.fake_clients import make_clients
from offboard.models import OffboardRequest
from offboard.planner import build_plan


def main(argv: list[str] | None = None) -> int:
    p = argparse.ArgumentParser(description="Offboard a user from the request in a ticket JSON.")
    p.add_argument("request", help="path to the offboarding request JSON")
    p.add_argument("--apply", action="store_true", help="make changes (default is dry run)")
    p.add_argument("--today", type=date.fromisoformat, default=date.today(),
                   help="override today's date, YYYY-MM-DD")
    p.add_argument("--state", default="state.json", help="fake API state file")
    args = p.parse_args(argv)

    with open(args.request) as f:
        request = OffboardRequest.from_dict(json.load(f))

    workspace, github = make_clients(args.state)
    plan = build_plan(request, workspace, github, args.today)
    entries = execute(plan, workspace, github, apply=args.apply)

    mode = "APPLY" if args.apply else "DRY RUN"
    print(f"Offboarding {request.name} <{request.email}>, ticket {request.ticket_id}, {mode}")
    for e in entries:
        print(e)
    return 1 if any(e.status == "failed" for e in entries) else 0


if __name__ == "__main__":
    sys.exit(main())
