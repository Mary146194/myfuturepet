// Runs JavaScript in the web page itself. On web, <model-viewer> lives in the
// app's own DOM and never reports a WebView controller, so the screen asks the
// page directly. Mobile uses the WebView controller instead.
export 'page_js_stub.dart' if (dart.library.js_interop) 'page_js_web.dart';
