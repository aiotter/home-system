{ lib, ... }:

{
  imports =
    ./.
    |> builtins.readDir
    |> lib.foldlAttrs (
      acc: filename: type:
      let
        isNix =
          if type == "directory" then
            builtins.pathExists ./${filename}/default.nix
          else if type == "regular" then
            filename != "default.nix" && lib.hasSuffix ".nix" filename
          else
            false;
      in
      if isNix then acc ++ [ ./${filename} ] else acc
    ) [ ];
}
