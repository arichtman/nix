{
  den.aspects.trust = {
    nixos = {
      security = {
        pki.certificateFiles = [
          (builtins.fetchurl {
            url = "https://www.richtman.au/root-ca.pem";
            sha256 = "1n0mmybs4alnr0zw049nm01sbrrhkj3idan917lcc6p8ils17psh";
          })
        ];
      };
    };
  };
}
