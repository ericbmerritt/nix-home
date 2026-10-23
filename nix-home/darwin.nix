{
  config,
  lib,
  ...
}: {
  home = {
    sessionPath = lib.mkAfter ["/opt/homebrew/bin" "/opt/homebrew/sbin"];

    # Sparkle cannot update cmux inside the read-only Nix store.
    activation.disableCmuxSparkle = lib.hm.dag.entryAfter ["writeBoundary"] ''
      run /usr/bin/defaults write com.cmuxterm.app SUEnableAutomaticChecks -bool false
      run /usr/bin/defaults write com.cmuxterm.app SUAutomaticallyUpdate -bool false
    '';
  };

  programs.ssh.includes = ["${config.home.homeDirectory}/.colima/ssh_config"];
}
