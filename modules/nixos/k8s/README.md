# Kubernetes module

I wasn't happy with the amount I had to hack at the existing module plus I needed to learn.

It's tough to think where to draw the boundary of control for Kubernetes or containers.
In theory everything down to `etcd` could be containerized.
Alternatively, once API server and `etcd` are up,
we could use a static pod running `addon-manager` which could then in turn
manage a Helm deployment of Flux/ArgoCD, or even the rest of the cluster's stuff directly.
That could include `kube-proxy`, the controllers, etc.

We must keep core Kubernetes components in-sync version-wise.
For this requirement it'd be fine if we could Helm/Flux - *all* the core components.
In fact, keeping some of them managed by Kubernetes and not Nix could be good,
keep them from fighting each other for control.
Alas, we still have to bootstrap some of the components in Nix,
so all in Nix it shall be.

I'm unclear why the `etcd` module uses environment variables instead of a config file.
I don't love it but I'm not making this hole any deeper lest I strike lava.
