{
  applyPatches,
  linkFarm,
}:

{
  mkPatchedComponentSource =
    component:
    applyPatches {
      name = "home-assistant-custom-component-${component.domain}-source";
      inherit (component) src domain;
      patches = component.patches or [ ];
    };

  collectCustomComponentSources =
    componentSources:
    linkFarm "home-assistant-custom-components" (
      map (componentSource: {
        name = componentSource.domain;
        path = "${componentSource}/custom_components/${componentSource.domain}";
      }) componentSources
    );
}
