# External DNS

- Anonymous k8s oidc - done
- DDNS domain for k8s service discovery - done
- Nginx configuration for k8s service discovery endpoints only - done
  Case-insensitive path match: `/(.well-known|openid)/.*`
- AWS IdP for cluster - done
- Roles for cluster service accounts - done

Notes:

- Tried using LB type svc for Kubernetes.
  It's a bit wonky as you have to manually configure the backend EndpointSlice.
  Unfortunately, the cluster's TLS certificate isn't trusted publicly.
- Publishing the VIP manually to Route53 worked, and could be fine for a bootstrapping step.
- We _can_ actually just publish thumbprints to AWS but I don't like that this'll break and need intervention.
- AWS IdP discovery is v4-only - because fuck you that's why.

```
export AWS_ROLE_ARN=arn:aws:iam::806676312179:role/k8s.richtman.au/external-dns@kube-system
export AWS_ROLE_SESSION_NAME=ariel
export AWS_DEFAULT_REGION=ap-southeast-2
export AWS_WEB_IDENTITY_TOKEN_FILE=./token.jwt
kubectl exec nginx -- cat /var/run/secrets/tokens/oidc-token > $AWS_WEB_IDENTITY_TOKEN_FILE
dog $AWS_WEB_IDENTITY_TOKEN_FILE | step crypto jwt inspect --insecure
nix run nixpkgs#awscli2 -- sts assume-role-with-web-identity  \
  --role-arn "${AWS_ROLE_ARN}" --role-session-name "${AWS_ROLE_SESSION_NAME}" --web-identity-token "file://${AWS_WEB_IDENTITY_TOKEN_FILE}"
```

## References

- [Official docs](https://kubernetes-sigs.github.io/external-dns/latest/)
- [Serviceaccount token auth](https://blog.vitalvas.com/post/2025/11/01/using-kubernetes-serviceaccount-token-for-auth-between-microservices/)
- [Hashicorp k8s OIDC docs](https://developer.hashicorp.com/vault/docs/auth/jwt/oidc-providers/kubernetes)
- [Structured authentication config spec](https://kubernetes.io/docs/reference/config-api/apiserver-config.v1/#apiserver-config-k8s-io-v1-AnonymousAuthCondition)
- [External JWT signer KEP](https://www.kubernetes.dev/resources/keps/740/#externaljwtsigner-rpc)
- [AWS OIDC IdP docs](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html)
- [AWS CLI env vars](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html)
- [AssumeRoleWithWebIdentity command](https://docs.aws.amazon.com/cli/latest/reference/sts/assume-role-with-web-identity.html)
- [AssumeRoleWithWebIdentity API](https://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRoleWithWebIdentity.html)
- [Kanidm Service Accounts with REST API](https://kanidm.github.io/kanidm/stable/accounts/service_accounts.html#api-tokens-with-kanidm-httpsrest-api)
- [My own OIDC+AWS fiddlings](https://github.com/arichtman/terraform-keycloak-aws-access)

## Generated policy

I think the audience condition is not effective, since I was able to assume role when the policy still had "aws" as the condition value.

```
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Principal": {
				"Federated": "arn:aws:iam::806676312179:oidc-provider/discovery.k8s.richtman.au"
			},
			"Action": "sts:AssumeRoleWithWebIdentity",
			"Condition": {
				"StringEquals": {
					"discovery.k8s.richtman.au:sub": "system:serviceaccount:default:default",
					"discovery.k8s.richtman.au:aud": "sts.amazonaws.com"
				}
			}
		}
	]
}
```
