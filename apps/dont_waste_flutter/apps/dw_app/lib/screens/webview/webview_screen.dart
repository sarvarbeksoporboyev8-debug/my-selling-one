import 'package:dw_ui/dw_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// In-app web browser for viewing external content like terms, privacy policy.
class WebViewScreen extends StatefulWidget {
  const WebViewScreen({
    super.key,
    required this.url,
    this.title,
  });

  /// URL to load.
  final String url;

  /// Title to display in the app bar. If null, uses page title.
  final String? title;

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  InAppWebViewController? _webViewController;
  double _progress = 0;
  String? _pageTitle;
  bool _canGoBack = false;
  bool _canGoForward = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title ?? _pageTitle ?? 'Loading...',
          style: const TextStyle(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _webViewController?.reload(),
            tooltip: 'Refresh',
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'open_browser':
                  final url = await _webViewController?.getUrl();
                  if (url != null) {
                    await InAppBrowser.openWithSystemBrowser(url: url);
                  }
                  break;
                case 'copy_link':
                  final url = await _webViewController?.getUrl();
                  if (url != null) {
                    // Copy to clipboard would go here
                  }
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'open_browser',
                child: ListTile(
                  leading: Icon(Icons.open_in_browser),
                  title: Text('Open in Browser'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
        bottom: _progress < 1.0
            ? PreferredSize(
                preferredSize: const Size.fromHeight(2),
                child: LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            : null,
      ),
      body: Column(
        children: [
          Expanded(
            child: InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(widget.url)),
              initialSettings: InAppWebViewSettings(
                useShouldOverrideUrlLoading: true,
                mediaPlaybackRequiresUserGesture: false,
                javaScriptEnabled: true,
                supportZoom: true,
                builtInZoomControls: true,
                displayZoomControls: false,
              ),
              onWebViewCreated: (controller) {
                _webViewController = controller;
              },
              onLoadStart: (controller, url) {
                setState(() {
                  _progress = 0;
                });
              },
              onProgressChanged: (controller, progress) {
                setState(() {
                  _progress = progress / 100;
                });
              },
              onLoadStop: (controller, url) async {
                setState(() {
                  _progress = 1.0;
                });
                _updateNavigationState();
              },
              onTitleChanged: (controller, title) {
                if (widget.title == null && title != null) {
                  setState(() {
                    _pageTitle = title;
                  });
                }
              },
              onLoadError: (controller, url, code, message) {
                _showError(context, message);
              },
              onLoadHttpError: (controller, url, statusCode, description) {
                if (statusCode >= 400) {
                  _showError(context, 'HTTP Error $statusCode');
                }
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildNavigationBar(theme),
    );
  }

  Widget _buildNavigationBar(ThemeData theme) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: _canGoBack ? null : theme.disabledColor,
            ),
            onPressed: _canGoBack ? () => _webViewController?.goBack() : null,
            tooltip: 'Back',
          ),
          IconButton(
            icon: Icon(
              Icons.arrow_forward_ios,
              color: _canGoForward ? null : theme.disabledColor,
            ),
            onPressed: _canGoForward ? () => _webViewController?.goForward() : null,
            tooltip: 'Forward',
          ),
        ],
      ),
    );
  }

  Future<void> _updateNavigationState() async {
    final canGoBack = await _webViewController?.canGoBack() ?? false;
    final canGoForward = await _webViewController?.canGoForward() ?? false;
    
    if (mounted) {
      setState(() {
        _canGoBack = canGoBack;
        _canGoForward = canGoForward;
      });
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error loading page: $message'),
        backgroundColor: AppColors.error,
      ),
    );
  }
}
