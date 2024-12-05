# https://discourse.nixos.org/t/how-to-build-the-zig-language-server-using-zig-overlay-nix-flake/43580/3
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    zig-overlay.url = "github:mitchellh/zig-overlay";
    zls-overlay.url = "github:zigtools/zls";
  };
  outputs = inputs @ {
    self,
    nixpkgs,
    ...
  }:
  let
    pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
    # zig = inputs.zig-overlay.packages.x86_64-linux.default;

    # aa7d138462602e086aacf738e4b92bfa3372bebe
    # zig = inputs.zig-overlay.packages.x86_64-linux.master-2024-12-01;
    #
    # zls = inputs.zls-overlay.packages.x86_64-linux.zls.overrideAttrs (old: {
    #         nativeBuildInputs = [ inputs.zig-overlay.packages.x86_64-linux.master-2024-12-01 ];
    #       });
  in
  {
    devShells.x86_64-linux.default = pkgs.mkShell {
      packages = [
        # zls
        # zig
      ];

      buildInputs = [
        pkgs.glfw

        pkgs.vulkan-tools
        pkgs.vulkan-headers
        pkgs.vulkan-loader
        pkgs.shaderc
      ];


      VK_INCLUDE_PATH = "${pkgs.vulkan-headers}/include";
      VK_LIB_PATH = "${pkgs.vulkan-loader}/lib";

      shellHook = ''
        unset WAYLAND_DISPLAY;
        $SHELL
        exit
      '';
    };
  };
}

