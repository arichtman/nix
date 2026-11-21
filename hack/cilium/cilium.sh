# Cilium working stuff

# helm repo add cilium https://helm.cilium.io/

function delete_all_nodes () { kubectl delete node $(kubectl get nodes --no-headers | awk '{print $1;}') -i=false ; }
function delete_all_cilium_nodes () { kubectl delete ciliumnodes --all -i=false ; }
function delete_all_cilium_resources () { kubectl api-resources | grep -i cilium | cut -d' ' -f1 | xargs -I% kubectl delete % --all -i=false ; }
function systemctl_all_nodes () { dog ../nodes.txt | xargs -I% ssh %.systems.richtman.au sudo systemctl $@ ; }
function label_nodes () { ../label.sh ; }
function validate_values () { jsonschema-cli validate ~/Downloads/cilium/values.schema.json -i ./values.yaml ; }
function helm_install () { validate_values && helm upgrade --install cilium cilium/cilium --namespace kube-system --values values.yaml --version 1.20.4 ; }
function apply_bgp () { kubectl apply -f ./bgp.yaml ; }

# Takes systemctl subcommand optionally so we can full reboot
# Removes k8s service just in case it's borked or holding stale IPs
function full_reset () {
  : clear out anything remaining from cilium connectivity test
  k delete ns cilium-test-1 cilium-test-ccnp1 cilium-test-ccnp2 -i=false
  : Delete any of our own testing
  kubectl delete ns lb-test -i=false
  helm -n kube-system uninstall cilium ;
  kubectl -n default delete svc kubernetes -i=false
  delete_all_nodes ;
  delete_all_cilium_nodes ;
  delete_all_cilium_resources ;
  : This hangs indefinitely unless we delete services referencing it, which requires intervention to Helm reinstall
  : k delete servicecidr kubernetes -i=false
  systemctl_all_nodes "${1:-restart k8s-kubelet}" ;
  echo "sleeping 3 minutes for restart"
  sleep 180 ;
  kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.6.1/standard-install.yaml
  label_nodes ;
  helm_install ;
  : For some reason envoy breaks first time with this release
  : echo "Sleeping briefly for come-up" ; sleep 30 ; kubectl rollout restart ds/cilium-envoy ;
  cilium status --wait ;
  apply_bgp ;
}
alias cbra='cilium bgp routes available ipv6 unicast'
alias cbp='cilium bgp peers'
# cilium bgp routes advertised ipv6 unicast
# Check CR statuses for errrors, general misconfig
# kd CiliumBGPClusterConfig cilium-bgp
# kd CiliumBGPPeerConfig primary-router
# kd CiliumBGPNodeConfig $n
function cdbg_any () { kubectl -n kube-system exec ds/cilium -- cilium-dbg $@ ; }
function cdbg_pod () { k exec -n kube-system -it $p -- cilium-dbg $@ }
alias cdbg=cdbg_any
# cdbg status --verbose
# cdbg service list
# cdbg bpf metrics list
# cdbg bpf lb list
# cdbg bpf nat list
# cdbg monitor --type drop
# cdbg bpf map get cilium_lb6_services_v2
# cdbg bpf map get cilium_lb6_backends_v3
# Check operator and agent logs
# kubectl -n kube-system logs $(kgp -l app.kubernetes.io/name=cilium-operator --no-headers | head -1 | cut -d' ' -f1) | grep "bgp"
# kubectl -n kube-system logs $(kgp -l app.kubernetes.io/name=cilium-agent --no-headers -owide | grep -i $node | cut -d' ' -f1) | grep "bgp"

# Test reaching the kubernetes API
function default_api_service_test () { kubectl run apiservertest --image=nicolaka/netshoot --rm -it --restart=Never -- nc -zvw 2 fd2f:f92f:f268:ffff::1 443; }
# Test reaching the back IP for kubernetes internally
function default_api_ip_test () { kubectl run apiservertest --image=nicolaka/netshoot --rm -it --restart=Never -- nc -zvw 2 $(kubectl -n default get endpointslice kubernetes -ojson | jq -r ' .endpoints[0].addresses[0] ') 6443; }
# DNS tests
# Resolve external address
function e_t () { kubectl run dnstest --image=nicolaka/netshoot --rm -it --restart=Never --command -- nslookup -type=AAAA example.com; }
# Resolve internal short
function i_t () { kubectl run dnstest --image=nicolaka/netshoot --rm -it --restart=Never --command -- nslookup -type=AAAA kubernetes.default; }
# Resolve internal fully qualified
function fi_t () { kubectl run dnstest --image=nicolaka/netshoot --rm -it --restart=Never --command -- nslookup -type=AAAA kubernetes.default.svc.cluster.local. ; }

function get_operator_pod () { kgp -l app.kubernetes.io/name=cilium-operator -ojson | jq ' .items[].metadata.name ' -r ; }
alias clog='stern -l app.kubernetes.io/name=cilium-operator'
