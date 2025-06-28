# Proxmox IPv6

Host interface enabling SLAAC.
- Configure Proxmox IPv6 SLAAC.

Dynamic v6 with static v4 might be bugged.

Seems issues with SLAAC on bridges - makes sense since which EUI64 when many MAC.

`/etc/network/interfaces`

```
iface vmbr0 inet6 static auto
        accept_ra 2 # Accept RA even with IP forwarding on
        autoconf # Presumably SLAAC
        privext 2 # Prefer privacy addresses
```

## References

- [Tutorial blog](https://blog.khmersite.net/p/configure-ipv6-for-proxmox-host-via-slaac/)
- [Debian docs](https://wiki.debian.org/NetworkConfiguration)
- [Reddit comment on SLAAC bridges](https://www.reddit.com/r/Proxmox/comments/oq2rgi/comment/h6amdp6/)
- [Proxmox forum](https://forum.proxmox.com/threads/ve-8-0-4-how-to-enable-ipv6-on-host-port.136373/post-604664)
