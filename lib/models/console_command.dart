class ConsoleCommand {
  ConsoleCommand({this.name, this.args, this.help, this.call, this.validate});

  final String name;
  final List<dynamic> args;
  final String help;

  final void Function(List<dynamic>) call;
  final Function validate;

  ConsoleCommand copyWith({
    List<dynamic> args,
  }) {
    return ConsoleCommand(
      name: name,
      args: args,
      help: help,
      call: call,
      validate: validate,
    );
  }
}
