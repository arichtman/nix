{pkgs, ...}: {
  lineWidth = 160;
  json = {
    indentWidth = 2;
  };
  plugins = with pkgs;
    dprint-plugins.getPluginList (
      plugins:
        with dprint-plugins; [
          dprint-plugin-toml
          dprint-plugin-markdown
          dprint-plugin-json
          dprint-plugin-dockerfile
        ]
    );
}
