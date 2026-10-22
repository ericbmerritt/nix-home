{config}: let
  home = config.home-manager.users.eric;
  packageNames = map (package: package.pname or package.name) home.home.packages;
  piDefaults = builtins.fromJSON (builtins.readFile ../nix-home/personal/pi-settings.json);
in
  config.assertions
  ++ [
    {
      assertion = config.nixpkgs.hostPlatform.system == "x86_64-linux" && config.system.nixos.release == "26.05";
      message = "Lascasas must retain its architecture and NixOS release.";
    }
    {
      assertion = config.fileSystems."/".device == "/dev/disk/by-uuid/3b8226fb-5421-4bf0-9dc9-5e10bfb6370d" && config.fileSystems."/".fsType == "ext4";
      message = "Lascasas root must remain on the existing SSD filesystem.";
    }
    {
      assertion = config.fileSystems."/boot".device == "/dev/disk/by-uuid/0156-66E8" && config.fileSystems."/boot".fsType == "vfat";
      message = "Lascasas must retain its existing EFI filesystem.";
    }
    {
      assertion = config.boot.loader.systemd-boot.enable && config.boot.loader.efi.canTouchEfiVariables && builtins.elem "megaraid_sas" config.boot.initrd.availableKernelModules;
      message = "Lascasas requires UEFI systemd-boot and its PERC initrd driver.";
    }
    {
      assertion = config.hardware.cpu.intel.updateMicrocode && config.boot.blacklistedKernelModules == ["acpi_power_meter"];
      message = "Lascasas must retain microcode updates and the power-meter workaround.";
    }
    {
      assertion = config.networking.hostName == "lascasas" && config.networking.networkmanager.enable;
      message = "Lascasas must retain its hostname and NetworkManager configuration.";
    }
    {
      assertion = config.users.users.eric.isNormalUser && builtins.elem "wheel" config.users.users.eric.extraGroups && config.users.mutableUsers;
      message = "Lascasas must retain Eric's administrator account and mutable password state.";
    }
    {
      assertion = config.users.users.eric.openssh.authorizedKeys.keys == ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID9wXYxlwnmE4jm7EpzxEPS6sVXowEiaEsXS6FjJSXCO emerritt@ip-192-168-1-100.us-west-2.compute.internal"];
      message = "Lascasas must retain its existing authorized SSH key.";
    }
    {
      assertion = config.services.openssh.enable && !config.services.openssh.settings.PasswordAuthentication && !config.services.openssh.settings.KbdInteractiveAuthentication && config.services.openssh.settings.PermitRootLogin == "no";
      message = "Lascasas must retain key-only SSH with root login disabled.";
    }
    {
      assertion = config.programs.ssh.startAgent && builtins.elem "default.target" config.systemd.user.services.ssh-agent.wantedBy && builtins.match ".*-a %t/ssh-agent" config.systemd.user.services.ssh-agent.serviceConfig.ExecStart != null;
      message = "Lascasas must start its user SSH agent at the managed runtime socket.";
    }
    {
      assertion = builtins.all (name: builtins.elem name packageNames) ["herdr" "pi-coding-agent"] && config.users.users.eric.packages == [home.home.path];
      message = "Home Manager must own Eric's personal coding-agent packages.";
    }
    {
      assertion = config.system.stateVersion == "26.05" && config.swapDevices == [];
      message = "Lascasas must retain its state version and existing swap configuration.";
    }
    {
      assertion = config.home-manager.useGlobalPkgs && config.home-manager.useUserPackages && home.home.username == "eric" && home.home.homeDirectory == "/home/eric" && home.home.stateVersion == "26.05";
      message = "Lascasas must use its base packages and the fresh personal Home Manager state version.";
    }
    {
      assertion = (config.environment.variables.GH_HOST or null) == null && (home.home.sessionVariables.GH_HOST or null) == null && (home.programs.git.settings.user.email or null) != "emerritt@whitepages.com" && (home.programs.jujutsu.settings.user.email or null) != "emerritt@whitepages.com";
      message = "Lascasas must not inherit company environment or identity.";
    }
    {
      assertion = builtins.all (file: !file.force && builtins.match "\\.pi/agent(/.*)?" file.target == null) (builtins.attrValues home.home.file) && config.home-manager.backupFileExtension == null && !config.home-manager.overwriteBackup && builtins.elem "writeBoundary" home.home.activation.piDefaults.after && builtins.elem "writeBoundary" home.home.activation.checkPiSettings.before;
      message = "Pi runtime files must remain writable and unmanaged; defaults must respect activation boundaries.";
    }
    {
      assertion =
        piDefaults
        == {
          defaultProvider = "openai";
          defaultModel = "gpt-6.1-sol";
        }
        && !home.fonts.fontconfig.enable;
      message = "The headless personal profile must declare only the approved Pi model defaults, without device identity or credentials.";
    }
  ]
