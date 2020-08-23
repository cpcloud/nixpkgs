{ callPackage }:
{
  decoder = callPackage ./decoder.nix { };
  decoder-op = callPackage ./decoder-op.nix { };
  decoder-tflite-plugin = callPackage ./decoder-tflite-plugin.nix { };
}
