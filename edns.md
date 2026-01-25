# External DNS

```bash
helm repo add edns https://kubernetes-sigs.github.io/external-dns/
helm repo update
helm pull edns/external-dns --version 1.20.0
helm upgrade --install --namespace external-dns --create-namespace external-dns ./external-dns-1.20.0.tgz
```

## References

- [Offical docs](https://kubernetes-sigs.github.io/external-dns/latest/)
- [eDNS Unbound webhook (good for testing without authoritative NS)](https://github.com/guillomep/external-dns-unbound-webhook)
- [RFC2136](https://datatracker.ietf.org/doc/html/rfc2136)
