{
  buildHomeAssistantComponent,
  fetchFromGitHub,
  ecdsa,
  crc,
  pycryptodome,
  protobuf,
}:

buildHomeAssistantComponent rec {
  owner = "rabits";
  domain = "ef_ble";
  version = "v0.8.7";

  src = fetchFromGitHub {
    owner = "rabits";
    repo = "ha-ef-ble";
    rev = version;
    hash = "sha256-aIvCFOKdk4FTqtmGeSzUuzyha9fimfNRNAUc8lQVzt4=";
  };

  dependencies = [ ecdsa crc pycryptodome protobuf ];

  ignoreVersionRequirement = [ "protobuf" ];
}
