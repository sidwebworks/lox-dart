import 'dart:io';

import 'package:path/path.dart';

import '../lib/interpreter.dart';

main(List<String> args) async {
  if (args.length > 1) {
    Interpreter.report("info", "Usage: lox [script]");
    exit(64);
  }

  final interpreter = Interpreter();

  if (args.length == 1) {
    File file = File(args[0]);

    Interpreter.input = basename(file.path);

    await interpreter.exec(file);
  } else {
    Interpreter.input = 'stdin';

    await interpreter.prompt();
  }
}
