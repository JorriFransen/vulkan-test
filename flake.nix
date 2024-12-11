# https://discourse.nixos.org/t/how-to-build-the-zig-language-server-using-zig-overlay-nix-flake/43580/3
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };
  outputs = inputs @ {
    self,
    nixpkgs,
    ...
  }:
  let
    pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
  in
  {
    devShells.x86_64-linux.default = pkgs.mkShell {
      packages = [
        # zls
        # zig
      ];

      buildInputs = [
        pkgs.glfw

        pkgs.xorg.libX11
        pkgs.wayland

        pkgs.vulkan-tools
        pkgs.vulkan-headers
        pkgs.vulkan-loader
        pkgs.vulkan-validation-layers
        pkgs.shaderc
      ];


      VK_INCLUDE_PATH = "${pkgs.vulkan-headers}/include";
      VK_LIB_PATH = "${pkgs.vulkan-loader}/lib";
      VK_LAYER_PATH = "${pkgs.vulkan-validation-layers}/share/vulkan/explicit_layer.d";

      shellHook = ''
        # unset WAYLAND_DISPLAY;
      '';
    };
  };
}

