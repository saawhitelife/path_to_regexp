import 'escape.dart';
import 'token.dart';

/// The default pattern used for matching parameters.
const _defaultPattern = '([^/]+?)';
const _endPattern = '([^/?]+?)';

/// The regular expression used to extract parameters from a path specification.
///
/// Capture groups:
///   1. The parameter name.
///   2. An optional pattern.
final _parameterRegExp = RegExp(/* (1) */ r':(\w+)'
    /* (2) */ r'(\((?:\\.|[^\\()])+\))?');

/// Parses a [path] specification.
///
/// Parameter names are added, in order, to [parameters] if provided.
List<Token> parse(String path, {List<String>? parameters}) {
  final matches = _parameterRegExp.allMatches(path);
  final tokens = <Token>[];
  var start = 0;
  var index = 0;
  final length = matches.length;
  for (final match in matches) {
    if (match.start > start) {
      tokens.add(PathToken(path.substring(start, match.start)));
    }
    final name = match[1]!;
    final optionalPattern = match[2];
    final pattern = optionalPattern != null
        ? escapeGroup(optionalPattern)
        : index == length - 1
            ? _endPattern
            : _defaultPattern;
    tokens.add(ParameterToken(name, pattern: pattern));
    parameters?.add(name);
    start = match.end;
    index++;
  }
  if (start < path.length) {
    tokens.add(PathToken(path.substring(start)));
  }

  return tokens;
}
