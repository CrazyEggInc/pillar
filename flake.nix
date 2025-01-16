{
  description = "CrazyEgg pillar fork";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{ parts, ... }:
    parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      perSystem =
        { pkgs, ... }:
        let
          beamPackages = pkgs.beam_minimal.packages.erlang_27;
          erlang = beamPackages.erlang;
          elixir = beamPackages.elixir_1_18;

          fetchMixDeps = beamPackages.fetchMixDeps.override {
            inherit elixir;
          };
          mixRelease = beamPackages.mixRelease.override {
            inherit erlang elixir fetchMixDeps;
          };
        in
        {
          devShells = {
            default = pkgs.mkShell {
              packages = with pkgs; [
                erlang
                elixir

                # tools
                (elixir_ls.override {
                  inherit elixir fetchMixDeps mixRelease;
                })
              ];
              env = {
                ERL_AFLAGS = "+pc unicode -kernel shell_history enabled";
                ELIXIR_ERL_OPTIONS = "+fnu +sssdio 128";
              };
            };
          };
        };
    };
}
