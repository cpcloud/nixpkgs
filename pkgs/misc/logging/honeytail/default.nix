{ stdenv, fetchFromGitHub, buildGoPackage }:
buildGoPackage rec {
  pname = "honeytail";
  version = "1.1.4";

  src = fetchFromGitHub {
    owner = "honeycombio";
    repo = "honeytail";
    rev = "v${version}";
    sha256 = "0yvcwv46kzip44c78zzcv1dink854p6zq84w8vrxipvximipwdcn";
  };

  goDeps = ./deps.nix;

  goPackagePath = "github.com/honeycombio/honeytail";

  meta = with stdenv.lib; {
    homepage = "https://github.com/honeycombio/honeytail";
    license = licenses.asl20;
    maintainers = with maintainers; [ cpcloud ];
    platforms = platforms.linux;
  };
}
