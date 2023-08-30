import 'dart:io';

import '../lib/interpreter.dart';

main(List<String> args) {
  if (args.length > 1) {
    stdout.writeln("Usage: lox [script]");
    exit(64);
  }

  final interpreter = Interpreter();

  if (args.length == 1) {
    interpreter.exec(args[0]);
  } else {
    interpreter.prompt();
  }
}
