{ callPackage }:
{
  engine-native = callPackage ./engine-native.nix { };
  engine = callPackage ./engine.nix { };
  resource-manager = callPackage ./resource-manager.nix { };
}
