{ stdenv
, fetchFromGitHub
, autoPatchelfHook
, libcxx
, libcxxabi
, lib
}:
let
  pname = "edgetpu-compiler";
  version = "14.1";
in
stdenv.mkDerivation {
  inherit pname version;
  src = fetchFromGitHub {
    owner = "google-coral";
    repo = "edgetpu";
    rev = "eel2";
    sha256 = "1ipzirrdqi1h3zmzz23662dlw6czzjz6iya8v7923gc4i1lz0wwm";
  };
  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ libcxx libcxxabi ];
  dontBuild = true;
  dontConfigure = true;
  installPhase = ''
    mkdir -p $out/bin
    chmod +x compiler/x86_64/edgetpu_compiler_bin/edgetpu_compiler
    cp compiler/x86_64/edgetpu_compiler_bin/edgetpu_compiler $out/bin
  '';

  meta = {
    description = "Edge TPU model compiler.";
    homepage = "https://coral.ai/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ cpcloud ];
    platforms = [ "x86_64-linux" ];
  };
}
