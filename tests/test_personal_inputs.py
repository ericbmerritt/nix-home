"""Integration contracts for the actual personal lock graph."""

import json
import unittest
from pathlib import Path


class PersonalInputTests(unittest.TestCase):
    def test_complete_graph_uses_only_approved_public_sources(self) -> None:
        lock = json.loads(
            (Path(__file__).resolve().parents[1] / "flake.lock").read_text()
        )
        inputs = lock["nodes"][lock["root"]]["inputs"]
        expected_pins = {
            "nixpkgs": ("NixOS", "nixpkgs", "cd4ea8d57de16f4810bc5f14207bac45fbf19f67"),
            "agent-nixpkgs": (
                "NixOS",
                "nixpkgs",
                "7a6522c868711d06e3a520bbcdfafe9806f4337f",
            ),
            "home-manager": (
                "nix-community",
                "home-manager",
                "24f8f8e786f87d6a818e1746cb2389bf922afdab",
            ),
        }
        self.assertEqual(set(inputs), set(expected_pins))
        self.assertEqual(set(lock["nodes"]), {lock["root"], *inputs.values()})
        for name, (owner, repo, revision) in expected_pins.items():
            node = lock["nodes"][inputs[name]]
            for field in ("original", "locked"):
                with self.subTest(input=name, field=field):
                    source = node[field]
                    self.assertEqual(source["type"], "github")
                    self.assertEqual(source.get("host", "github.com"), "github.com")
                    self.assertEqual((source["owner"], source["repo"]), (owner, repo))
                    self.assertEqual(source["rev"], revision)
        home_manager = lock["nodes"][inputs["home-manager"]]
        self.assertEqual(home_manager["inputs"], {"nixpkgs": ["nixpkgs"]})


if __name__ == "__main__":
    unittest.main()
