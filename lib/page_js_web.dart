import 'dart:js_interop';
import 'dart:js_interop_unsafe';

/// Evaluates [script] in the page and returns its result as a string.
Future<Object> evalPageJs(String script) async {
  final result = globalContext.callMethod<JSAny?>('eval'.toJS, script.toJS);
  return result.dartify()?.toString() ?? 'null';
}
