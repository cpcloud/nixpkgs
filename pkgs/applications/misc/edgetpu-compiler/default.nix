{ stdenv
, fetchurl
, dpkg
, autoPatchelfHook
, libcxx
, libcxxabi
, lib
}:
let
  pname = "edgetpu-compiler";
  sha256 = "ef6eef29200270dcb941d2c1defa39c7d80e9c6f30cf7ced1c653a30bde0a502";
  version = "14.1";
in
stdenv.mkDerivation {
  inherit pname version;
  src = fetchurl {
    url = "https://packages.cloud.google.com/apt/pool/${pname}_${version}_amd64_${sha256}.deb";
    inherit sha256;
  };
  nativeBuildInputs = [ dpkg autoPatchelfHook ];
  buildInputs = [ libcxx libcxxabi ];
  unpackCmd = ''
    mkdir ./src
    dpkg -x $src ./src
  '';
  installPhase = ''
    chmod +x ./usr/bin/edgetpu_compiler_bin/edgetpu_compiler
    install -D ./usr/bin/edgetpu_compiler_bin/edgetpu_compiler $out/bin/edgetpu_compiler
  '';

  meta = {
    description = "Edge TPU model compiler.";
    homepage = "https://coral.ai/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ cpcloud ];
    platforms = [ "x86_64-linux" ];
  };
}
