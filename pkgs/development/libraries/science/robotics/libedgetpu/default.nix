{ stdenv
, autoPatchelfHook
, libusb
, lib
, tensorflow-lite
, fetchFromGitHub
  # enable maximum TPU clock frequency
, enableMax ? false
}:
let
  # TODO: how to enforce that only max or std can be in the closure, never both?
  kind = if enableMax then "direct" else "throttled";
  pname = "libedgetpu1-${if enableMax then "max" else "std"}";
  archs = {
    x86_64-linux = "k8";
    aarch64-linux = "aarch64";
  };
  arch = archs.${stdenv.system};
in
stdenv.mkDerivation rec {
  inherit pname;
  version = "14.1";
  outputs = [ "out" "dev" ];
  src = fetchFromGitHub {
    owner = "google-coral";
    repo = "edgetpu";
    rev = "eel2";
    sha256 = "1ipzirrdqi1h3zmzz23662dlw6czzjz6iya8v7923gc4i1lz0wwm";
  };
  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ libusb stdenv.cc.cc.lib tensorflow-lite ];
  installPhase = ''
    # udev rules
    mkdir -p $out/etc/udev
    cp libedgetpu/edgetpu-accelerator.rules $out/etc/udev

    # libs
    mkdir -p $out/lib
    cp libedgetpu/${kind}/${arch}/libedgetpu* $out/lib

    # symlink libedgetpu.so -> libedgetpu.so.1 to allow linking via -ledgetpu
    ln -s $out/lib/libedgetpu.so{.1,}

    # includes
    mkdir -p $dev/include
    cp libedgetpu/*.h $dev/include
  '';

  dontBuild = true;
  dontConfigure = true;

  meta = with stdenv.lib; {
    description = "Core libraries for Coral Edge TPU devices.";
    homepage = "https://coral.ai/";
    license = licenses.asl20;
    maintainers = with maintainers; [ cpcloud ];
    platforms = lib.attrNames archs;
  };
}
