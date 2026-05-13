{ buildHomeAssistantComponent }:

{
  setup_assistant = buildHomeAssistantComponent {
    owner = "aiotter";
    domain = "setup_assistant";
    version = "0.1.0";
    src = ./setup_assistant;
  };
}
