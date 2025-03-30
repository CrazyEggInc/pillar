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
          beamPackages = pkgs.beam.packages.erlang_27;
          erlang = beamPackages.erlang;
          elixir = beamPackages.elixir_1_18;
        in
        {
          devShells = {
            default = pkgs.mkShell {
              packages = with pkgs; [
                erlang
                elixir
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
