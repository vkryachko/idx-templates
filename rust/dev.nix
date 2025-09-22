# To learn more about how to use Nix to configure your environment
# see: https://developers.google.com/idx/guides/customize-idx-env
{ pkgs, lib, ... }:
let
  ttyd = pkgs.writeShellScript "code-oss" ''
    rm -rf /run/idx/code-oss.sock 
    ${
      /*
        This files needs to be readable and writable by nginx to be able to proxy to the unix
         domain socket. As soon as the file is created and chmod'ed, this bash subshell wil exit.
      */
      ""
    } 
    { 
      while [ ! -S /run/idx/code-oss.sock ]; 
        do sleep 1; 
      done 
      chmod a+rw /run/idx/code-oss.sock 
    } & 

    cmd=( 
      ${pkgs.ttyd}/bin/ttyd -t fontFamily="FiraCode Nerd Font" -i /run/idx/code-oss.sock -W gemini 
    ) 
    exec "''${cmd[@]}" 
  '';
in
{
  # Which nixpkgs channel to use.
  channel = "stable-24.05"; # or "unstable"
  # Use https://search.nixos.org/packages to find packages
  packages = [
    pkgs.cargo
    pkgs.rustc
    pkgs.rustfmt
    pkgs.stdenv.cc
  ];
  # Sets environment variables in the workspace
  env = {
    RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";
  };
  idx = {
    # Search for the extensions you want on https://open-vsx.org/ and use "publisher.id"
    extensions = [
      "rust-lang.rust-analyzer"
      "tamasfe.even-better-toml"
      "serayuzgur.crates"
      "vadimcn.vscode-lldb"
    ];
    workspace = {
      onCreate = {
        # Open editors for the following files by default, if they exist:
        default.openFiles = ["src/main.rs"];
      };
    };
    # Enable previews and customize configuration
    previews = {};
  };
  processes.code-oss = lib.mkForce {
    command = "${ttyd}";
    env = {
      COLORTERM = "truecolor";
    };
  };
}
