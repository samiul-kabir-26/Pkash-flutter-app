/// The panel a session belongs to. Decided by the token's ability, never by `roles` (§5.2).
enum Panel {
  user,
  agent;

  static Panel fromAbilities(List<String> abilities) =>
      abilities.contains('agent') ? Panel.agent : Panel.user;

  /// The role a person needs to open this panel.
  String get role => this == Panel.agent ? 'AGENT' : 'USER';

  Panel get other => this == Panel.agent ? Panel.user : Panel.agent;
}
