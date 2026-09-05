{pkgs}: let
  # Ref: https://kubernetes.io/docs/reference/config-api/apiserver-config.v1beta1/
  # Ref: https://kubernetes.io/docs/reference/config-api/apiserver-config.v1/
  authConfig = {
    apiVersion = "apiserver.config.k8s.io/v1";
    kind = "AuthenticationConfiguration";
    jwt = [
      {
        issuer = {
          url = "https://id.richtman.au/oauth2/openid/k8s";
          audiences = ["k8s"];
          # audienceMatchPolicy = "MatchAny";
        };
        claimMappings = {
          uid = {
            claim = "sub";
          };
          username = {
            expression = "claims.preferred_username";
          };
          groups = {
            expression = "claims.groups";
          };
          extra = [
            {
              key = "k8s.richtman.au/email";
              valueExpression = "claims.email";
            }
            # TODO: Fix CEL
            # jwt[0].claimMappings.extra[1].valueExpression: Invalid value: "size(claims.groups.filter(g, g == \"k8s_admins@id.richtman.au\")) == 1": compilation failed: ERROR: <input>:1:12: expression of type 'any' cannot be range of a comprehension (must be list, map, or dynamic)
            # size(claims.groups.filter(g, g == "k8s_admins@id.richtman.au")) == 1
            # ___________^
            # valueExpression = ''size(claims.groups.filter(g, g == "k8s_admins@id.richtman.au")) == 1'';
            # {
            #   key = "k8s.richtman.au/admin";
            #   # This one is returning false for me even though I'm in the admin group...
            #   valueExpression = ''string("k8s_admins@id.richtman.au" in claims.groups)'';
            # }
          ];
        };
        claimValidationRules = [
          {
            expression = "claims.email_verified == true";
            message = "Only verified users, soz";
          }
        ];
        userValidationRules = [
          # TODO: Add validation for email domain too?
          {
            # This one's kinda redundant cause this IdP is always @richtman.au
            # Well... unless we add some IdPs to it as upstreams?
            expression = ''user.username.endsWith("@id.richtman.au")'';
            message = "Kool kids only, mum keep out";
          }
          {
            expression = "!user.username.startsWith('system:')";
            message = "system: is a reserved username prefix";
          }
        ];
      }
    ];
    anonymous = {
      enabled = true;
      conditions = [
        {path = "/livez";}
        {path = "/readyz";}
        {path = "/healthz";}
        {path = "/metrics";} # Note: this still needs RBAC bindings else `system:anonymous` can't perform Get on it
      ];
    };
  };
in
  pkgs.writeText "auth-config" (builtins.toJSON authConfig)
