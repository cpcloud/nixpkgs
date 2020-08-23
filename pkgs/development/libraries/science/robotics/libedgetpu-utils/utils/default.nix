{ callPackage }:
{
  error-reporter = callPackage ./error-reporter.nix { };
  utils = callPackage ./utils.nix { };
  version = callPackage ./version.nix { };
}
