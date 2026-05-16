final: prev:

let
  inherit (final) lib;
in

{
  glances = prev.glances.overridePythonAttrs { doCheck = false; };

  home-assistant-custom-components =
    let
      components = prev.home-assistant-custom-components;
    in
    components
    // {
      ecoflow_cloud = components.ecoflow_cloud.overridePythonAttrs (old: {
        patches = old.patches or [ ] ++ [
          (final.fetchpatch {
            name = "add-wave3-support.diff";
            url = "https://github.com/tolwi/hassio-ecoflow-cloud/pull/762.diff";
            hash = "sha256-RZBnPg+vD1XrbWJ/9ZN5GL2tfh1k0hZsYMyYnL1iRVk=";
          })
        ];
      });
    };
}
