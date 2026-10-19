"""Check work lock wiring without fetching any private inputs."""

import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class WorkInputTests(unittest.TestCase):
    def test_coordinated_work_pins_match_the_captured_baseline(self) -> None:
        lock = json.loads((ROOT / "flakes/work/flake.lock").read_text())
        baseline = json.loads((ROOT / "checks/work-laptop-baseline.json").read_text())
        inputs = lock["nodes"][lock["root"]]["inputs"]
        work = lock["nodes"][inputs["whitepages-nix"]]
        for input_name, baseline_name in (
            ("nixpkgs", "nixpkgs"),
            ("home-manager", "homeManager"),
            ("nix-darwin", "nixDarwin"),
            ("nixpkgs-unstable", "unstable"),
        ):
            with self.subTest(input=input_name):
                pinned = lock["nodes"][work["inputs"][input_name]]["locked"]
                self.assertEqual(pinned["rev"], baseline["pins"][baseline_name])
        for name in ("nixpkgs", "home-manager", "nix-darwin"):
            self.assertEqual(inputs[name], ["whitepages-nix", name])

    def test_private_sources_are_published_and_pinned_together(self) -> None:
        lock = json.loads((ROOT / "flakes/work/flake.lock").read_text())
        inputs = lock["nodes"][lock["root"]]["inputs"]
        sources = [
            lock["nodes"][inputs[name]] for name in ("pagecraft", "whitepages-nix")
        ]
        self.assertEqual(sources[0]["locked"]["rev"], sources[1]["locked"]["rev"])
        for source in sources:
            for field in ("original", "locked"):
                with self.subTest(field=field):
                    self.assertEqual(source[field]["type"], "git")
                    self.assertEqual(
                        source[field]["url"],
                        "ssh://git@github.dev.pages/whitepages-meta/monorepo",
                    )
                    self.assertRegex(source[field]["rev"], r"^[0-9a-f]{40}$")

    def test_shared_source_is_relative_and_keeps_personal_pins_independent(
        self,
    ) -> None:
        lock = json.loads((ROOT / "flakes/work/flake.lock").read_text())
        root = json.loads((ROOT / "flake.lock").read_text())
        inputs = lock["nodes"][lock["root"]]["inputs"]
        shared = lock["nodes"][inputs["personal"]]
        self.assertEqual(shared["locked"], {"path": "../..", "type": "path"})
        self.assertEqual(shared["parent"], [])
        public = lock["nodes"][shared["inputs"]["nixpkgs"]]["locked"]
        self.assertEqual(
            public,
            root["nodes"][root["nodes"][root["root"]]["inputs"]["nixpkgs"]]["locked"],
        )


if __name__ == "__main__":
    unittest.main()
