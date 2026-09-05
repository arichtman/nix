{
  den.aspects.localization = {
    nixos = {
      # Set your time zone.
      time.timeZone = "UTC";

      # Select internationalisation properties.
      i18n.defaultLocale = "C.UTF-8";

      i18n.extraLocaleSettings = {
        LC_ADDRESS = "C.UTF-8";
        LC_IDENTIFICATION = "C.UTF-8";
        LC_MEASUREMENT = "C.UTF-8";
        LC_MONETARY = "C.UTF-8";
        LC_NAME = "C.UTF-8";
        LC_NUMERIC = "C.UTF-8";
        LC_PAPER = "C.UTF-8";
        LC_TELEPHONE = "C.UTF-8";
        LC_TIME = "C.UTF-8";
      };
    };
  };
}
