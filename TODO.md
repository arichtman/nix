# TODO

- Ensure kubelet systemd service does not launch without either containerd up or /run/containerd/containerd.sock existing.
- Simplify opening firewall locally, both TCP+UDP and the unstructured/free textness.
  [Ref](https://unix.stackexchange.com/questions/448209/how-to-match-both-udp-and-tcp-for-given-ports-in-one-line-with-nftables)
- Fix Bazzite Steam launch.
  I think deck mode is broken but `steam steam://open/bigpicture` works.
  Need to locate the config for default launch parameters.
  [login/logout info](https://www.reddit.com/r/Bazzite/comments/1ddwucj/comment/l9ae5c9/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button)
  There's some `bazzite-*.desktop` files under `/usr/share/xdg/desktop` that point at some `/usr/bin/steam-*` scripts.
  Might also be some `ujust` subcommand that reaches it.
  Probably no need for [disabling GPU rendering](https://github.com/ValveSoftware/steam-for-linux/issues/10561#issuecomment-5599216049) as thought.
- Fix spelling of coffee in router LL-address
