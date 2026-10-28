# Mac notes

System DNS resolution: `dscacheutil -q host -a name example.com`

Routing: `netstat -rn -f inet6`

Interfaces: `ifconfig en0`

## Developer tooling

https://corrode.dev/blog/tips-for-faster-rust-compile-times/#macos-only-exclude-rust-compilations-from-gatekeeper

## Work Mac FD limits

```
sysctl -w kern.maxfilesperproc=20480
sudo launchctl limit maxfiles 128000 524288
ulimit -n 524288 10485760
```

- [SE](https://apple.stackexchange.com/questions/462489/how-to-increase-global-max-opened-files-limit-on-osx-13-5-ventura)
- [SO](https://stackoverflow.com/questions/5377450/maximum-number-of-open-filehandles-per-process-on-osx-and-how-to-increase)
