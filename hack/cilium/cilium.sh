# Cilium working stuff

# helm repo add cilium https://helm.cilium.io/

function delete_all_nodes () { kubectl delete node $(kubectl get nodes --no-headers | awk '{print $1;}') -i=false ; }
function delete_all_cilium_nodes () { kubectl delete ciliumnodes --all -i=false ; }
function delete_all_cilium_resources () { kubectl api-resources | grep -i cilium | cut -d' ' -f1 | xargs -I% kubectl delete % --all -i=false ; }
function systemctl_all_nodes () { dog ../nodes.txt | xargs -I% ssh %.systems.richtman.au sudo systemctl $@ ; }
function label_nodes () { ../label.sh ; }
function validate_values () { jsonschema-cli validate ~/Downloads/cilium/values.schema.json -i ./values.yaml ; }
function helm_install () { validate_values && helm upgrade --install cilium cilium/cilium --namespace kube-system --values values.yaml --version 1.20.2 ; }
function apply_bgp () { kubectl apply -f ./bgp.yaml ; }
# Takes systemctl subcommand optionally so we can full reboot
# Removes k8s service just in case it's borked or holding stale IPs
function full_reset () {
  : clear out anything remaining from cilium connectivity test
  k delete ns cilium-test-1 cilium-test-ccnp1 cilium-test-ccnp2 -i=false
  : Delete any of our own testing
  kubectl delete ns lb-test -i=false
  helm uninstall coredns ;
  helm uninstall cilium ;
  kubectl -n default delete svc kubernetes -i=false
  delete_all_nodes ;
  delete_all_cilium_nodes ;
  delete_all_cilium_resources ;
  systemctl_all_nodes "${1:-restart k8s-kubelet}" ;
  sleep 180 ;
  label_nodes ;
  helm_install ;
  sleep 15 ;
  : For some reason it breaks first time
  kubectl rollout restart ds/cilium-envoy ;
  cilium status --wait ;
  apply_bgp ;
}
alias cbra='cilium bgp routes available ipv6 unicast'
alias cbp='cilium bgp peers'
function cdbg_any () { kubectl -n kube-system exec ds/cilium -- cilium-dbg $@ ; }
function cdbg_pod () { k exec -n kube-system -it $p -- cilium-dbg $@ }
alias cdbg=cdbg_any
# cdbg status --verbose
# cdbg service list
# cdbg bpf metrics list
# cdbg bpf lb list
# cdbg bpf nat list
# cdbg monitor --type drop
# Test reaching the kubernetes API
function default_api_service_test () { kubectl run apiservertest --image=nicolaka/netshoot --rm -it --restart=Never -- nc -zvw 2 fda6:3c52:d12b::1 443; }
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
# stern -l app.kubernetes.io/name=cilium-operator
