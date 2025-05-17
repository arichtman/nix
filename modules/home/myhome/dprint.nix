{pkgs, ...}: {
  lineWidth = 160;
  json = {
    indentWidth = 2;
  };
  plugins = pkgs.dprint-plugins.getPluginList (
    plugins: [
      pkgs.dprint-plugins.dprint-plugin-toml
      pkgs.dprint-plugins.dprint-plugin-markdown
      pkgs.dprint-plugins.dprint-plugin-json
      pkgs.dprint-plugins.dprint-plugin-dockerfile
    ]
  );
}
