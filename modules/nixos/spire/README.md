# Spire

- `DynamicUser` option hides the socket in a mount namespace.
  Not sure how crippling this is but I don't think it's possible to
  disable `PrivateTmp` once `DynamicUser` is enabled.
- Revisit the trust domain, I think just `richtman.au` is better.
- Looks like arbitrary binaries are callable for plugins.
  We should write one for node attestation.
- Agent is failing to persist SVIDs to disk causing a need for
  new join token every restart.
- Should avoid unverified bootstrapping.
  Unclear how we should be able to retrieve the trust bundle.
  I can't locate a proper API spec like Swagger/OpenAPI.
- Confirm there is no REST API, it's all RPC.
- Had intermittent failure connecting to DBUS socket.
  Hope that stays away.
- Provide own trust, should be able to override the default
  self-signed root CA.
  Unsure if this should come from Step or not.
- Set Step-CA as upstream?
- Only one workload attestor allowed :/
  Will have to duplicate agents for k8s.
- `NodeAttestor` _x509pop_ might suit as we wanted SSH certs anyways.

```
# Generate a join token
nsenter -t $(pgrep spire-server) -a spire-server token generate -spiffeID 'spiffe://systems.richtman.au/fat-controller'
```
