{ lib, vscode-utils }:

let
  inherit (vscode-utils) buildVscodeMarketplaceExtension;
in
buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "vscode-wakatime";
    publisher = "WakaTime";
    version = "25.0.4";
    hash = "sha256-J+H/PShsOGwt0AZExLApXLl86XQdZbE5cPS9v4gOXWc=";
  };

  meta = {
    description = ''
      Visual Studio Code plugin for automatic time tracking and metrics generated
      from your programming activity
    '';
    license = lib.licenses.bsd3;
  };
}
