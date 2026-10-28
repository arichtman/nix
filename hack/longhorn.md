# Longhorn

```bash
helm repo add longhorn https://charts.longhorn.io
helm repo update
helm pull longhorn/longhorn --version 1.10.1
helm install longhorn ./longhorn-1.10.1.tgz --namespace longhorn-system --create-namespace
```

## References

- [Official docs](https://longhorn.io/docs/1.10.1/)
