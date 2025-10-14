{
  description = "Flake for redun-psij-executor";
  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/25.05"; # until eRI supports later than Nix 2.17 😢

    flake-utils.url = "github:numtide/flake-utils";
    redun = {
      url = "github:AgResearch/redun.nix/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    inputs.flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import inputs.nixpkgs {
            inherit system;
          };

          flakePkgs = {
            redun = inputs.redun.packages.${system}.default;
          };

          psij-python = with pkgs;
            python3Packages.buildPythonPackage {
              name = "psij";
              src = pkgs.fetchFromGitHub {
                owner = "ExaWorks";
                repo = "psij-python";
                rev = "0.9.11";
                hash = "sha256-Gp85E95ulIodp23d/LYK1Olinwv6zqb+p4fO6evnm3I=";
              };

              format = "setuptools";

              # Tests seem to require a network-mounted home directory
              doCheck = false;

              nativeBuildInputs = with python3Packages;
                [
                  setuptools
                ];

              buildInputs = with python3Packages;
                [
                  packaging
                ];

              propagatedBuildInputs = with python3Packages;
                [
                  psutil
                  pystache
                  typeguard
                ];
            };

          pyproject = builtins.fromTOML (builtins.readFile ./pyproject.toml);

          redun-psij-executor = with pkgs;
            python3Packages.buildPythonPackage {
              pname = "redun-psij-executor";
              version = pyproject.project.version;
              src = ./.;
              pyproject = true;

              nativeBuildInputs = [
                hatch
                python3Packages.hatchling
              ];

              propagatedBuildInputs = [
                psij-python
                flakePkgs.redun
              ];
            };

        in
        with pkgs;
        {
          devShells = {
            default = mkShell
              {
                buildInputs =
                  let
                    python-with-dependencies = (pkgs.python3.withPackages (ps: [
                      psij-python
                      flakePkgs.redun
                    ]));
                  in
                  [
                    bashInteractive
                    hatch
                    python-with-dependencies
                    python3Packages.pytest
                    jsonnet
                  ];

                shellHook = ''
                  # enable use of this package from current directory during development
                  export PYTHONPATH=$(pwd)/src:$PYTHONPATH
                '';
              };
          };

          packages = {
            # The default package is the unbundled Python package for use in other flakes.
            default = redun-psij-executor;

            inherit redun-psij-executor psij-python;
          };

          apps = {
            eri-install = {
              type = "app";
              program = "${eri-install}/bin/eri-install.gbs_prism";
            };

            tests = let test-environment = python3.withPackages (ps: [ ps.pytest ]); in {
              type = "app";
              program = "${writeShellScript "redun-psij-executor-tests" ''
                export PATH=${pkgs.lib.makeBinPath [test-environment]}
                export PYTHONPATH=$(pwd)/src:$PYTHONPATH
                pytest src
              ''}";
            };
          };
        }
      );
}
