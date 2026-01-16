import 'dart:io';

import 'package:dw_ui/dw_ui.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

/// Screen for viewing PDF documents from URL or local file.
/// Uses Syncfusion PDF Viewer for search, bookmarks, and annotations support.
class PdfViewerScreen extends StatefulWidget {
  const PdfViewerScreen({
    super.key,
    this.url,
    this.filePath,
    this.title,
  }) : assert(url != null || filePath != null, 'Either url or filePath must be provided');

  /// URL of the PDF to load (remote).
  final String? url;

  /// Local file path of the PDF.
  final String? filePath;

  /// Title to display in the app bar.
  final String? title;

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  PdfViewerController? _pdfController;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  PdfTextSearchResult? _searchResult;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfViewerController();
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    _searchController.dispose();
    _searchResult?.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchResult?.clear();
        _searchController.clear();
      }
    });
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      _searchResult?.clear();
      return;
    }
    _searchResult = _pdfController?.searchText(query);
    _searchResult?.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: _isSearching ? _buildSearchAppBar(theme) : _buildNormalAppBar(theme),
      body: _buildBody(context),
    );
  }

  PreferredSizeWidget _buildNormalAppBar(ThemeData theme) {
    return AppBar(
      title: Text(
        widget.title ?? 'Document',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: _toggleSearch,
          tooltip: 'Search',
        ),
        IconButton(
          icon: const Icon(Icons.bookmark_outline),
          onPressed: () => _pdfViewerKey.currentState?.openBookmarkView(),
          tooltip: 'Bookmarks',
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'zoom_in':
                _pdfController?.zoomLevel = (_pdfController?.zoomLevel ?? 1) + 0.25;
                break;
              case 'zoom_out':
                _pdfController?.zoomLevel = (_pdfController?.zoomLevel ?? 1) - 0.25;
                break;
              case 'fit_width':
                _pdfController?.zoomLevel = 1.0;
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'zoom_in',
              child: ListTile(
                leading: Icon(Icons.zoom_in),
                title: Text('Zoom In'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'zoom_out',
              child: ListTile(
                leading: Icon(Icons.zoom_out),
                title: Text('Zoom Out'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'fit_width',
              child: ListTile(
                leading: Icon(Icons.fit_screen),
                title: Text('Fit to Width'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  PreferredSizeWidget _buildSearchAppBar(ThemeData theme) {
    final hasResults = _searchResult != null && _searchResult!.totalInstanceCount > 0;
    
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: _toggleSearch,
      ),
      title: TextField(
        controller: _searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Search in document...',
          border: InputBorder.none,
          hintStyle: TextStyle(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        style: theme.textTheme.bodyLarge,
        onSubmitted: _performSearch,
        onChanged: (value) {
          if (value.length >= 3) {
            _performSearch(value);
          }
        },
      ),
      actions: [
        if (hasResults) ...[
          Text(
            '${_searchResult!.currentInstanceIndex}/${_searchResult!.totalInstanceCount}',
            style: theme.textTheme.bodySmall,
          ),
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_up),
            onPressed: () => _searchResult?.previousInstance(),
            tooltip: 'Previous',
          ),
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down),
            onPressed: () => _searchResult?.nextInstance(),
            tooltip: 'Next',
          ),
        ],
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            _searchController.clear();
            _searchResult?.clear();
          },
          tooltip: 'Clear',
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    if (widget.url != null) {
      return SfPdfViewer.network(
        widget.url!,
        key: _pdfViewerKey,
        controller: _pdfController,
        canShowScrollHead: true,
        canShowScrollStatus: true,
        enableDoubleTapZooming: true,
        enableTextSelection: true,
        onDocumentLoadFailed: (details) => _showError(context, details.description),
      );
    }

    if (widget.filePath != null) {
      return SfPdfViewer.file(
        File(widget.filePath!),
        key: _pdfViewerKey,
        controller: _pdfController,
        canShowScrollHead: true,
        canShowScrollStatus: true,
        enableDoubleTapZooming: true,
        enableTextSelection: true,
        onDocumentLoadFailed: (details) => _showError(context, details.description),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No document to display',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to load PDF: $message'),
        backgroundColor: AppColors.error,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }
}
