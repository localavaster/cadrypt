class ConsoleCommand {
  ConsoleCommand(this.name, this.args, this.help, this.onCall);

  final String name;
  final List<Type> args;
  final String help;
  final Function onCall;
}
