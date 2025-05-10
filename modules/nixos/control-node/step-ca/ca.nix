{
  root = "/var/lib/step-ca/certs/root_ca.crt";
  federatedRoots = null;
  crt = "/var/lib/step-ca/certs/intermediate_ca.crt";
  key = "/var/lib/step-ca/secrets/intermediate_ca_key";
  address = "[::]:7443";
  insecureAddress = "";
  dnsNames = [
    "fat-controller.systems.richtman.au"
    "fat-controller.local"
    "fat-controller.internal"
    "ca.richtman.au"
  ];
  logger = {
    format = "text";
  };
  db = {
    type = "badgerv2";
    dataSource = "/var/lib/step-ca/db";
    # dataSource = "/var/lib/private/step-ca/db";
    # badgerFileLoadingMode = "";
  };
  authority = {
    provisioners = [
      {
        type = "JWK";
        name = "ariel@richtman.au";
        key = {
          use = "sig";
          kty = "EC";
          kid = "SwnQyfEsuxKN6eVxWcpuCKllIxGuEExMjvKTAoke9yA";
          crv = "P-256";
          alg = "ES256";
          x = "K3ibxE1dThWSFRsG5fUiJjhwjYAz1dyVMeX9fEgswQ8";
          y = "S9BnS1Q2PpsuJ1O5V2tA4cGJtobj14nIDnBZ08dX67g";
        };
        encryptedKey = "eyJhbGciOiJQQkVTMi1IUzI1NitBMTI4S1ciLCJjdHkiOiJqd2sranNvbiIsImVuYyI6IkEyNTZHQ00iLCJwMmMiOjYwMDAwMCwicDJzIjoiNFpRWDh3RFB0V1BNbWM3dWlUS2htdyJ9.uxOSZNJRfihd5vhGaZpWJaX5XWhtdtLG7K9UeQZwCWf16VwcWUgH9A.hyCH7xbKfLMcPhX-.0xSkFWL49A58fTx47Bt_racnOuV_jfDmpE05DeFJSg5C8W0ikTwOSPEaO_rN3JzF7n977leW-1F_VNxzXQv25MuguObJmnAWPTbvSLrX9z_O7DG1c-dxkh5GxW38rTYYWulP9J1eZhS4reqZGobWqbuLyXkrL5OG9BiubbNQFPuDIsEvQ0Ts9Tf44ySaU2_F5UuB_xIwPtzhshFMTrZlr9vB3iN12aMIpaggtkM5c1f7T2lCZL4Ec-heEkOOmIlPFaG4wNgRCDUp8jfzenkSClWuCDgggvDHwiZR7vmDoek3BUrysMplhxERzWLmC0_dWdVrzjvQ2QwpocZJ2zY.ZDwrwSZioQT_2CrnzXD7fg";
      }
    ];
  };
  tls = {
    cipherSuites = [
      "TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256"
      "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256"
    ];
    minVersion = 1.2;
    maxVersion = 1.3;
    renegotiation = false;
  };
}
