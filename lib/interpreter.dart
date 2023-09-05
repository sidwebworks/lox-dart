import 'dart:convert';
import 'dart:io';

import 'package:lox/scanner/scanner.dart';

import 'package:chalkdart/chalk.dart';
import 'package:lox/scanner/token.dart';

print_prompt() {
  stdout.write(chalk.brightRed.bold('>'));
  stdout.write(chalk.brightCyan.bold('>'));
  stdout.write(chalk.brightGreen.bold('>'));
}

class Interpreter {
  static var errored = false;
  static String input = 'stdin';

  Interpreter();

  static error(
    int line,
    int col,
    String msg,
  ) {
    String trace = chalk.gray('${chalk.cyan(input)}:$line:$col');
    String message = "$msg at $trace";
    Interpreter.report('error', message);
    Interpreter.errored = true;
  }

  static report(
    String type,
    String msg,
  ) {
    String pre;

    switch (type) {
      case "info":
        pre = chalk.blue.bold('Info');
        break;
      case "warning":
        pre = chalk.yellow.bold('Warning');
        break;
      case "error":
        pre = chalk.red.bold('Error');
        break;
      case "debug":
        pre = chalk.gray.bold('Debug');
        break;
      default:
        pre = chalk.blue.bold(type);
    }

    String message = "[$pre] $msg";

    stdout.writeln(message);
  }

  prompt() async {
    try {
      Interpreter.input = 'stdin';

      for (;;) {
        print_prompt();

        String? line = stdin.readLineSync(
          encoding: utf8,
        );

        line = line?.trim();

        if (line == 'exit()') break;

        if (line == '' || line == null) {
          Interpreter.report(
              'info', 'Type exit() and Press (ctrl + c) to exit');
          continue;
        }

        await run(line);

        if (Interpreter.errored) exit(65);
      }

      Interpreter.report('info', 'Exiting...');
      exit(0);
    } catch (e) {
      Interpreter.report('error', e.toString());
    }
  }

  exec(File file) async {
    try {
      final stopwatch = Stopwatch();

      stopwatch.start();

      List<String> lines = await file.readAsLines(encoding: utf8);

      String code = lines.join('\n');

      await run(code);

      stopwatch.stop();

      stdout.writeln(); // Newline

      Interpreter.report(
          'info', 'Finished in ${stopwatch.elapsedMilliseconds}ms');
    } catch (e, trace) {
      Interpreter.report("error", e.toString());
      print(trace.toString());
    }
  }

  run(String code) async {
    Scanner scanner = Scanner(code);

    List<Token> tokens = scanner.scan();

    print(tokens);
  }
}
