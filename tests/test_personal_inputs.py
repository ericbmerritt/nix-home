"""Integration contracts for the actual personal lock graph."""

import json
import unittest
from pathlib import Path


class PersonalInputTests(unittest.TestCase):
    def test_complete_graph_uses_only_approved_public_sources(self) -> None:
        lock = json.loads(
            (Path(__file__).resolve().parents[1] / "flake.lock").read_text()
        )
        self.assertEqual(set(lock["nodes"][lock["root"]]["inputs"]), {"nixpkgs"})
        for name, node in lock["nodes"].items():
            if name == lock["root"]:
                continue
            for field in ("original", "locked"):
                with self.subTest(node=name, field=field):
                    source = node[field]
                    self.assertEqual(source["type"], "github")
                    self.assertEqual(source.get("host", "github.com"), "github.com")
                    self.assertEqual(
                        (source["owner"], source["repo"]), ("NixOS", "nixpkgs")
                    )
                    self.assertEqual(
                        source["rev"], "cd4ea8d57de16f4810bc5f14207bac45fbf19f67"
                    )


if __name__ == "__main__":
    unittest.main()
