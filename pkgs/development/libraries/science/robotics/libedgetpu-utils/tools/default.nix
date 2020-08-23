{ callPackage }:
{
  tflite-graph-util = callPackage ./tflite-graph-util.nix { };
  join-tflite-models = callPackage ./join-tflite-models.nix { };
}
