{
  pkgs,
  assertions,
}: let
  failures = builtins.filter (entry: !entry.assertion) assertions;
in
  assert pkgs.lib.assertMsg (failures == []) (pkgs.lib.concatMapStringsSep "\n" (entry: entry.message) failures);
    pkgs.runCommand "host-contracts" {} ''
      touch "$out"
    ''
