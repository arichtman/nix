# Kubernetes Auth

Configuring Kanidm as an Oauth provider for cluster identity.

Todo:

- Investigate additional properties for use in ABAC.
- ~Look at mapping additional roles to groups to see if we can stack permissions.~
  Able to bind multiple roles based on groups, haven't investigated if permissions stack though.
- ~Should fix or allow adding Prometheus target.~
  Anonymous auth now working for `/healthz`, `/livez`, `/readyz`, and `/metrics`.

```
kanidm system oauth2 create-public k8s fat-controller.systems.richtman.au https://fat-controller.systems.richtman.au:6443
# Can probably set this properly in initial create call
kanidm system oauth2 set-displayname k8s Kubernetes
# Port kept changing and was localhost for step-cli to catch the token
kanidm system oauth2 enable-localhost-redirects k8s

# Create and map group
kanidm group create k8s_users
# Set the client to map the scopes we need the claims of
kanidm system oauth2 update-scope-map k8s k8s_users openid email profile groups
# Add our user
kanidm group add-members k8s_users arichtman
# Repeat for k8s_admins group

# verify our work
kanidm system oauth2 get k8s
```

`~/.kube/config`:

```yaml
- name: oauth
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      command: kubectl
      args:
      - oidc-login
      - get-token
      - --oidc-issuer-url
      - https://id.richtman.au/oauth2/openid/k8s
      - --oidc-client-id
      - k8s
      - --oidc-extra-scope
      - 'openid profile groups email'
```

Note: maybe instead of extra scopes we do `--oidc-use-access-token` see [issue](https://github.com/int128/kubelogin/issues/1083).

Note: I suspect step-cli is dead on this one on two counts:
Firstly, we'll need to contruct another JSON output compatible with `client.authentication.k8s.io/v1beta1`.
Secondly, it seems to do not only no caching, but no refreshing either.

```
gh () { step --config step.json oauth $@ ; }
export K8=https://fat-controller.systems.richtman.au:6443
export STEP_PROVIDER=https://id.richtman.au/oauth2/openid/k8s
export STEP_CLIENT_ID=k8s
export STEP_SCOPE=openid,profile,groups,email
export STEP_LISTEN='localhost:0'
step oauth > token
curl $K8 -H "$(gh --header)" -k
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
