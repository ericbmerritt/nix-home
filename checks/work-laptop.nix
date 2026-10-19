{flake}: let
  actual = import ./work-facts.nix {inherit flake;};
  baseline = builtins.fromJSON (builtins.readFile ./work-laptop-baseline.json);
in
  map (name: {
    assertion = actual.${name} == baseline.${name};
    message = "Work laptop baseline changed in ${name}; review the evaluated difference before updating the fixture.";
  }) (builtins.attrNames baseline)
