# This file is generated by gradle2nix.

{ stdenvNoCC, lib, buildEnv, fetchurl }:

{ name, repositories, dependencies }:

let
  mkPath = artifact: with artifact; lib.concatStringsSep "/" [
    (lib.replaceChars ["."] ["/"] artifact.groupId)
    artifact.artifactId
    artifact.version
  ];

  mkFilename = artifact: with artifact;
    "${artifactId}-${version}${lib.optionalString (classifier != "") "-${classifier}"}.${extension}";

  mkArtifactUrl = base: artifact:
    "${lib.removeSuffix "/" base}/${mkPath artifact}/${mkFilename artifact}";

  fetchArtifact = artifact:
  let
    artifactPath = mkPath artifact;
    artifactName = mkFilename artifact;
  in stdenvNoCC.mkDerivation rec {
    name = with artifact; lib.concatStrings [
      (lib.replaceChars ["."] ["_"] groupId) "-"
      (lib.replaceChars ["."] ["_"] artifactId) "-"
      version
      (lib.optionalString (classifier != "") "-${classifier}")
      "-" type
    ];

    src = fetchurl {
      name = mkFilename artifact;
      urls = map (url: mkArtifactUrl url artifact) repositories;
      inherit (artifact) sha256;
    };

    phases = "installPhase fixupPhase";

    installPhase = ''
      mkdir -p $out/${artifactPath}
      ln -s ${src} $out/${artifactPath}/${artifactName}
    '';
  };

in
buildEnv {
  inherit name;
  paths = map fetchArtifact dependencies;
}
