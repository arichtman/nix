{
  pkgs,
  controllerKubeconfigFile,
  secretsPath,
}: let
  # Ref: https://kubernetes.io/docs/reference/config-api/kube-controller-manager-config.v1alpha1/
  controllerConfig = {
    apiVersion = "kubecontroller.config.k8s.io/v1alpha1";
    kind = "KubeControllerManagerConfiguration";
    generic = {
      clientConnection = {
        kubeconfig = controllerKubeconfigFile;
      };
    };
    CSRSigningController = {
      clusterSigningCertFile = "${secretsPath}/k8s-ca.pem";
      clusterSigningKeyFile = "${secretsPath}/k8s-ca-key.pem";
      # kubeletServingSignerConfiguration = {
      #   certFile = "";
      #   keyFile = "";
      # };
      # kubeletClientSignerConfiguration = {
      #   certFile = "";
      #   keyFile = "";
      # };
      # kubeAPIServerClientSignerConfiguration = {
      #   certFile = "";
      #   keyFile = "";
      # };
      # legacyUnknownSignerConfiguration = {
      #   certFile = "";
      #   keyFile = "";
      # };
      # clusterSigningDuration = "1h";
    };
  };
in
  pkgs.writeText "controller-config" (builtins.toJSON controllerConfig)
