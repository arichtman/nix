{
  # inputs,
  # den,
  ...
}: {
  # imports = [inputs.den.flakeModule];
  # den.schema.flake-system.includes = [den.aspects.default-shell];

  den.aspects.default-shell = {
    devShells = {pkgs, ...}: {
      default = pkgs.mkShell {
        packages = [
          pkgs.just
        ];

        buildInputs = with pkgs; [
          prek
    		];
  		};
		};
	};
}

