{pkgs, ...}: {
  imports = [./hardware-configuration.nix];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    blacklistedKernelModules = ["acpi_power_meter"];
  };

  networking = {
    hostName = "lascasas";
    networkmanager.enable = true;
  };

  users.users.eric = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager"];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID9wXYxlwnmE4jm7EpzxEPS6sVXowEiaEsXS6FjJSXCO emerritt@ip-192-168-1-100.us-west-2.compute.internal"
    ];
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  nix.settings.experimental-features = ["nix-command" "flakes"];
  environment.systemPackages = [pkgs.git];

  system.stateVersion = "26.05";
}
