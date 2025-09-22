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
  channel = "stable-24.11"; # or "unstable"
  # Use https://search.nixos.org/packages to find packages
  packages = [
    pkgs.nodejs_20
  ];
  # Sets environment variables in the workspace
  env = { };
  processes.code-oss = lib.mkForce {
    command = "${ttyd}";
    env = {
      COLORTERM = "truecolor";
    };
  };
}
