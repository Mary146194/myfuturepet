/// Not on web: there is no page to run JavaScript in.
Future<Object> evalPageJs(String script) =>
    Future.error(UnsupportedError('evalPageJs is web only'));
