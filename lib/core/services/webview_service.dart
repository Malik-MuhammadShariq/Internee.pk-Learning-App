import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// WebView service — manages cookie/session for Internee.pk
class WebViewService {
  /// Clear all WebView cookies (used by "Clear Internee.pk Session")
  Future<void> clearInterneeSession() async {
    await WebViewCookieManager().clearCookies();
  }
}

/// Provider for WebViewService
final webViewServiceProvider = Provider<WebViewService>((ref) {
  return WebViewService();
});
