rec {
  den.hosts.x86_64-linux.bruce-banner.users.arichtman = den.hosts.x86_64-linux.bluefin.users.arichtman;
  den.hosts.x86_64-linux.bluefin.users.arichtman = {
    userSettings = {
      git = {
        user = "Ariel Richtman";
        email = "";
      };
      stateVersion = "22.11";
    };
  };
}
