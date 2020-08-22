{ stdenv
, buildPythonPackage
, autoPatchelfHook
, fetchurl
, numpy
, pillow
, dpkg
, lib
, python
, enableMax
, libedgetpu-max
, libedgetpu-std
}:
let
  sha256s = {
    x86_64-linux = "c7e77f6ccddc7f32088429656eec477b1fc2decf8e1c6c1d029a34c3cc2300ae";
    aarch64-linux = "1ef0857cfe4253c4859a3d9985a0eb4127d6227b6e7ccb83d0c06e3b84a034a5";
  };

  system = stdenv.system;
  sha256 = sha256s.${system};

  debArchs = {
    x86_64-linux = "amd64";
    aarch64-linux = "arm64";
  };
  debArch = debArchs.${system};

  libedgetpu = if enableMax then libedgetpu-max else libedgetpu-std;
in
buildPythonPackage rec {
  pname = "python3-edgetpu";
  version = "14.1";

  src = fetchurl {
    url = "https://packages.cloud.google.com/apt/pool/${pname}_${version}_${debArch}_${sha256}.deb";
    inherit sha256;
  };

  nativeBuildInputs = [ dpkg autoPatchelfHook ];
  buildInputs = [ libedgetpu ];
  propagatedBuildInputs = [ numpy pillow ];
  format = "other";

  unpackCmd = ''
    mkdir ./src
    dpkg -x $src ./src
  '';
  installPhase = ''
    mkdir -p $out/${python.sitePackages}
    cp -r ./usr/lib/python3/dist-packages/edgetpu $out/${python.sitePackages}
  '';

  meta = with stdenv.lib; {
    description = "An easy-to-use Python API for working with Coral devices";
    homepage = "https://coral.ai/";
    license = licenses.asl20;
    maintainers = with maintainers; [ cpcloud ];
    platforms = lib.attrNames debArchs;
  };
}
