# DNS

Some diagnostic tests for mDNS:

```bash
export HOST_NAME=fat-controller.systems.richtman.au.
# This is our bedrock of truth. It works consistently and can be easily viewed
avahi-resolve-host-name $HOST_NAME
tcpdump udp port 5353 # Optionally -Qin
# Supposedly a good test according to Arch wiki, has not once worked for me.
getent ahosts $HOST_NAME
# Sometimes worked but timed out on a 3rd imaginary server. Most verbose but leaks mDNS queries.
dig $HOST_NAME
# Sometimes worked but not very helpful output.
host $HOST_NAME

# Convenience aliases
alias rollall='sudo systemctl restart NetworkManager systemd-resolved systemd-networkd; sudo systemctl daemon-reload'

alias dtest4='dig -4 $HOST_NAME'
alias dtest6='dig -6 $HOST_NAME'
alias htest4='host -4 $HOST_NAME'
alias htest6='host -6 $HOST_NAME'
alias etest='getent ahosts $HOST_NAME'

alltest() {
  dtest4
  dtest6
  htest4
  htest6
  etest
}

alias nm=nmcli
alias rc=resolvectl
alias as=authselect
```

So, turns out this whole resolution chain is a mess, some things use nsswitch, others don't etc.
We want consistent behaviour and caching, so we need the local stub resolver.
We want it even more if we're switching networks and VPNs as it can hold all the logic for changing shit.

Here's some locations and commands for config.
I tried valiantly to enable it at connection level and in nsswitch but ultimately there was always something that disobeyed the rules.

`/etc/nsswitch.conf`:

This should be managed by `authselect`.
Don't ask why.
Fun fact: apparently the `sssd` daemon totally doesn't need to be running for this to work.
Why is DNS is entwined with an auth config management tool?
Because go fuck yourself, that's why.
~ Poettering, probably.

```shell
authselect list
authselect current
authselect show sssd
# Yields some options
authselect select sssd with-mdns4 with-mdns6
```

`/etc/resolv.conf`:

This one is managed by NetworkManager.
Why is that capitalized?
NFI.
Go fuck yourself!
~ Probably Poettering, again.

I tried manually managing this one, no dice (to do that, stop NetworkManager, and remove the symlink).
Leave it symlinked to `/run/systemd/resolve/stub-resolve.conf`.
That's the managed file that will always point at the local stub resolver.
We can manage the actual settings with `nmcli`.
mDNS is configured per connection, not interface, which I guess makes sense for laptops/WiFi.

```shell
nmcli connection show
# I tried this as 2 (resolve+publish) and I think it clashes with the stub resolver
nmcli conn mod enp3s0 connection.mdns 2
nmcli conn mod sugar_monster_house connection.mdns 2
# Yea it breaks v4 resolution somehow
# Not sure about this one... In theory we lose the domains config as well as our Unbound upstream,
#   but resolved should have us covered? domain search might need to happen at the origin call site though.
nmcli conn mod enp3s0 ipv4.ignore-auto-dns no
nmcli conn mod enp3s0 ipv6.ignore-auto-dns no
```

Oh, the stub resolver doesn't actually run on `localhost:53`.
It's `127.0.0.53` (and actually `.54` also, according to `man 8 systemd-resolved.service`).
Can ya guess why?
Yup. Had enough self-love yet?
Keep reading.

`/etc/systemd/network/*.network`:

You can write files like:

```ini
[Network]
DHCP=yes
Domain=local internal
```

Except when I experimented `resolvectl` didn't edit the file and editing the file didn't show in `resolvectl` output.
So go figure.

I honestly can't keep track of what this is relative to _NetworkManager_.
There is a service, `systemd-networkd`.
By the way, `systemd-resolved` _used_ to be controlled by `systemd-resolve`.
It's now `resolvectl`.
Guess I'm not mad about that one.
Now the fact that mDNS is configured per _interface_ and not _connection_ like before?
Get fuuuuuucked.
Oh and the daemon only listens on IPv4 (at least by default).
GFY!

```shell
sudo resolvectl mdns enp0s3 yes
sudo resolvectl domain enp0s3 local internal
echo 'DNSStubListenerExtra=[::1]:53' | sudo tee -a /etc/systemd/resolved.conf
```

`/etc/NetworkManager`:

Whatever.

What worked in the end?
Well, still getting some odd behaviour with `host` and IPv6 but...
No files in `/etc/systemd/network`.
Disable `networkd`.
Resolvectl set +mdns.
Symlinked `/etc/resolv.conf` to the `resolved` stub file.
Configured `resolved`.
Avahi daemon enabled and running with defaults.

```shell
sudo systemctl disable --now systemd-networkd
sudo systemctl mask systemd-networkd
sudo systemctl daemon-reload
```

Final `/etc/systemd/resolved.conf`:

```ini
[Resolve]
DNS=192.168.1.1,2403:580a:e4b1:0:aab8:e0ff:fe00:91ef
Domains=local internal
MulticastDNS=yes
DNSStubListenerExtra=[::1]:53
```

References:

- [Some helpful soul](https://infosec.exchange/@ds/112663636510469329)
- [StackOverflow answer](https://unix.stackexchange.com/a/442599)
- [Arch wiki page](https://wiki.archlinux.org/title/Domain_name_resolution)
- [Blog post](https://wlog.viltstigen.se/articles/2021/05/02/mdns-for-linux/)
- [Arch forum thread](https://bbs.archlinux.org/viewtopic.php?id=271103)
- So many more misc. pages
