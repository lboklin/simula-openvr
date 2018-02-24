{ mkDerivation, hpack, fetchFromGitHub, aeson, base, bytestring, c2hs, containers, lens
, linear, openvr_api, stdenv, template-haskell, text, unix
}:
mkDerivation {
  pname = "simula-openvr";
  version = "0.0.0";

  src = ./.;

  preConfigure = ''
    ${hpack}/bin/hpack

    mkdir -p openvr/headers
    cp ${openvr_api}/include/openvr_api.json openvr/headers/
  '';

  libraryHaskellDepends = [
    aeson base bytestring containers lens linear template-haskell text
    unix
  ];
  librarySystemDepends = [ openvr_api ];
  libraryToolDepends = [ c2hs ];

  description = "Haskell bindings for OpenVR";
  license = "Apache-2.0";
}
