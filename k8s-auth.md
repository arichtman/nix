# Kubernetes Auth

Configuring Kanidm as an Oauth provider for cluster identity.

Todo:

- Investigate additional properties for use in ABAC.
- ~Look at mapping additional roles to groups to see if we can stack permissions.~
  Able to bind multiple roles based on groups, haven't investigated if permissions stack though.
- ~Should fix or allow adding Prometheus target.~
  Anonymous auth now working for `/healthz`, `/livez`, `/readyz`, and `/metrics`.

Note: maybe instead of extra scopes we do `--oidc-use-access-token` see [issue](https://github.com/int128/kubelogin/issues/1083).

[CEL playground](https://playcel.undistro.io/) input

[CEL spec](https://github.com/google/cel-spec/blob/v0.24.0/doc/langdef.md)

```yaml
claims:
  email: foo@richtman.au
  preferred_username: foo@id.richtman.au
  email_verified: true
  groups:
    - "idm_admins@id.richtman.au"
    - "idm_unix_admins@id.richtman.au"
    - "idm_oauth2_admins@id.richtman.au"
    - "idm_radius_service_admins@id.richtman.au"
    - "idm_account_policy_admins@id.richtman.au"
    - "idm_people_admins@id.richtman.au"
    - "idm_service_account_admins@id.richtman.au"
    - "idm_application_admins@id.richtman.au"
    - "idm_mail_service_admins@id.richtman.au"
    - "idm_group_admins@id.richtman.au"
    - "idm_all_persons@id.richtman.au"
    - "idm_all_accounts@id.richtman.au"
    - "idm_high_privilege@id.richtman.au"
    - "idm_people_self_name_write@id.richtman.au"
    - "idm_client_certificate_admins@id.richtman.au"
    - "ext_idm_provisioned_entities@id.richtman.au"
    - "grafana_superadmins@id.richtman.au"
    - "grafana_admins@id.richtman.au"
    - "grafana_editors@id.richtman.au"
    - "grafana_users@id.richtman.au"
    - "k8s_users@id.richtman.au"
    - "k8s_admins@id.richtman.au"
```

## References

- [k8s docs on auth config](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#using-authentication-configuration)
- [beta announcement](https://kubernetes.io/blog/2024/04/25/structured-authentication-moves-to-beta/)
- [KEP](https://github.com/kubernetes/enhancements/issues/3331)
- [Anonymous auth KEP](https://github.com/kubernetes/enhancements/blob/master/keps/sig-auth/4633-anonymous-auth-configurable-endpoints/README.md)
- [Blog on anonymous auth](https://medium.com/@azalio_16174/securing-kubernetes-api-server-health-checks-without-anonymous-access-0be907fbf5e8)
- [k8s metrics reference](https://kubernetes.io/docs/reference/instrumentation/metrics/)
- [Endpoints](https://id.richtman.au/oauth2/openid/k8s/.well-known/openid-configuration)
- [Video tutorial](https://www.youtube.com/watch?v=kQnXsTPCVXg)
- [Blog post](https://blog.stonegarden.dev/articles/2024/12/kubernetes-rbac/#openid-connect-authorisation)
- [Plugin docs](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#client-go-credential-plugins)
- [KEP for external credential providers](https://github.com/kubernetes/enhancements/blob/master/keps/sig-auth/541-external-credential-providers/README.md)
- [Issue requesting info on passing cluster info to plugin](https://github.com/kubernetes/website/issues/35641)
