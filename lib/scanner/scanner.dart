import 'package:lox/interpreter.dart';
import 'package:lox/scanner/token.dart';

class Scanner {
  List<Token> tokens = [];
  int start = 0;
  int current = 0;
  int line = 1;

  late String source;

  static final Map<String, TokenType> keywords = {
    "and": TokenType.AND,
    "class": TokenType.CLASS,
    "else": TokenType.ELSE,
    "false": TokenType.FALSE,
    "for": TokenType.FOR,
    "fn": TokenType.FUN,
    "if": TokenType.IF,
    "nil": TokenType.NIL,
    "or": TokenType.OR,
    "print": TokenType.PRINT,
    "return": TokenType.RETURN,
    "super": TokenType.SUPER,
    "this": TokenType.THIS,
    "let": TokenType.VAR,
    "true": TokenType.TRUE,
    "while": TokenType.WHILE,
  };

  Scanner(String source) {
    this.source = source;
  }

  List<Token> scan() {
    while (!this.isAtEnd()) {
      start = 0;
      scanToken();
    }

    tokens.add(new Token(TokenType.EOF, '', null, line));

    return tokens;
  }

  void scanToken() {
    String c = advance();

    switch (c) {
      case '(':
        addToken(TokenType.LEFT_PAREN);
        break;

      case ')':
        addToken(TokenType.RIGHT_PAREN);
        break;

      case '{':
        addToken(TokenType.LEFT_BRACE);
        break;

      case '}':
        addToken(TokenType.RIGHT_BRACE);
        break;

      case ',':
        addToken(TokenType.COMMA);
        break;

      case '.':
        addToken(TokenType.DOT);
        break;

      case '-':
        addToken(TokenType.MINUS);
        break;

      case '+':
        addToken(TokenType.PLUS);
        break;

      case ';':
        addToken(TokenType.SEMICOLON);
        break;

      case '*':
        addToken(TokenType.STAR);
        break;

      case '!':
        addToken(match('=') ? TokenType.BANG_EQUAL : TokenType.BANG);
        break;

      case '=':
        addToken(match('=') ? TokenType.EQUAL_EQUAL : TokenType.EQUAL);
        break;

      case '<':
        addToken(match('=') ? TokenType.LESS_EQUAL : TokenType.LESS);
        break;

      case '>':
        addToken(match('=') ? TokenType.GREATER_EQUAL : TokenType.GREATER);
        break;

      case 'o':
        if (match('r')) {
          addToken(TokenType.OR);
        }

        break;

      case '/':
        if (match('/')) {
          // A comment goes until the end of the line.
          while (peek() != '\n' && !isAtEnd()) advance();
        } else {
          addToken(TokenType.SLASH);
        }
        break;

      case '"':
        string();
        break;

      case ' ':
      case '\r':
      case '\t':
        // Ignore whitespace.
        break;

      case '\n':
        line++;
        break;

      case '\0':
        break;

      default:
        if (isDigit(c)) {
          number();
        } else if (isAlpha(c)) {
          identifier();
        } else {
          Interpreter.error(line, current, "Unexpected character \"$c\"");
        }
        break;
    }
  }

  identifier() {
    while (isAlphaNumeric(peek())) advance();

    String text = source.substring(start, current);

    TokenType type = keywords[text] ?? TokenType.IDENTIFIER;

    addToken(type);
  }

  string() {
    while (peek() != '"' && !isAtEnd()) {
      if (peek() == '\n') line++;
      advance();
    }

    if (isAtEnd()) {
      Interpreter.error(line, current, "Unterminated string");
      return;
    }

    // The closing ".
    advance();

    // Trim the surrounding quotes.
    String value = source.substring(start + 1, current - 1);

    addToken(TokenType.STRING, value);
  }

  number() {
    while (isDigit(peek())) advance();

    // Look for a fractional part.
    if (peek() == '.' && isDigit(peek(2))) {
      // Consume the "."
      advance();

      while (isDigit(peek())) advance();
    }

    final value = double.parse(source.substring(start, current));

    addToken(TokenType.NUMBER, value);
  }

  advance() {
    return source[current++];
  }

  bool isDigit(String input) {
    final c = input.codeUnitAt(0);
    return c >= 48 && c <= 57;
  }

  bool isAlpha(String input) {
    final c = input.codeUnitAt(0);
    return (c >= 97 && c <= 122) || (c >= 65 && c <= 90) || c == 95;
  }

  bool isAlphaNumeric(String c) {
    return isAlpha(c) || isDigit(c);
  }

  bool match(String expected) {
    if (isAtEnd()) return false;

    if (source[current] != expected) return false;

    current++;

    return true;
  }

  String peek([int offset = 1]) {
    if (isAtEnd()) return '\0';

    if (offset == 1) offset = current;

    return source[current];
  }

  addToken(TokenType type, [Object? literal]) {
    String text = source.substring(start, current);

    if (literal == null) literal = "";

    tokens.add(new Token(type, text, literal, line));
  }

  bool isAtEnd() {
    return current >= source.length;
  }
}
