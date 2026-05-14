{
  home-assistant,
}:

let
  inherit (home-assistant.python.pkgs) callPackage;
in

{
  setup_assistant = callPackage ./setup_assistant { };
}
