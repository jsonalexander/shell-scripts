{
  description = "Shell scripts";

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.zst";

		wayland-boomer.url = "github:jsonalexander/wayland-boomer-nix";
  };

  outputs = inputs: {
    packages = builtins.mapAttrs (system: pkgs: {

			scripts = {
				hello-world = pkgs.writeShellScript {
					name = "hello-world";
					text = ''
						echo "Hello, world!"
					'';
				};
			};

			swayScripts = {
				zoom = pkgs.writeShellApplication {
					name = "sway-zoom";

					runtimeInputs = let
						wayland-boomer = inputs.wayland-boomer.packages.${system}.default;
					in [
						wayland-boomer
						pkgs.grim
						pkgs.jq
					];

					text = ''
						output="$(swaymsg -t get_outputs | jq -r '.[] | select(.focused) | .name')"
						exec grim -o $output - | wayland-boomer
					'';
				};
			};

    }) inputs.nixpkgs.legacyPackages;

		overlays = builtins.mapAttrs (system: pkgs: let
			f = (name: value:
				pkgs.lib.warnIf <nixpkgs>.${system}.${name} != null
					"Script \"${name}\" overrides an existing package."
					(final: prev: value)
			);
		in
			builtins.mapAttrs f inputs.self.packages.${system}
		) inputs.nixpkgs.legacyPackages;
  };
}
