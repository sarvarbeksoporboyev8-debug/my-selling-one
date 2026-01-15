import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dw_ui/dw_ui.dart';

import '../../providers/providers.dart';
import '../../routing/app_routes.dart';

/// Search screen
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  List<String> _recentSearches = ['Bread', 'Vegetables', 'Dairy', 'Bakery'];

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.isEmpty) return;

    // Update filters with search query
    ref.read(filtersProvider.notifier).updateQuery(query);

    // Add to recent searches
    setState(() {
      _recentSearches.remove(query);
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 10) {
        _recentSearches = _recentSearches.take(10).toList();
      }
    });

    // Navigate to discover with search
    context.go(AppRoutes.discover);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: 'Search for food...',
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  )
                : null,
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: _performSearch,
          onChanged: (_) => setState(() {}),
        ),
        actions: [
          TextButton(
            onPressed: () => _performSearch(_searchController.text),
            child: const Text('Search'),
          ),
        ],
      ),
      body: _searchController.text.isEmpty
          ? _buildRecentSearches()
          : _buildSearchSuggestions(),
    );
  }

  Widget _buildRecentSearches() {
    if (_recentSearches.isEmpty) {
      return const Center(
        child: DwEmptyState(
          icon: Icons.search,
          title: 'Search for food',
          message: 'Find surplus food near you at discounted prices.',
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(DwSpacing.md),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Searches', style: DwTextStyles.titleMedium),
            TextButton(
              onPressed: () {
                setState(() => _recentSearches.clear());
              },
              child: const Text('Clear'),
            ),
          ],
        ),
        const SizedBox(height: DwSpacing.sm),
        ..._recentSearches.map((search) => ListTile(
              leading: const Icon(Icons.history),
              title: Text(search),
              trailing: IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () {
                  setState(() => _recentSearches.remove(search));
                },
              ),
              onTap: () {
                _searchController.text = search;
                _performSearch(search);
              },
            )),
      ],
    );
  }

  Widget _buildSearchSuggestions() {
    // TODO: Implement actual search suggestions from API
    final suggestions = [
      'Fresh ${_searchController.text}',
      '${_searchController.text} near me',
      'Organic ${_searchController.text}',
    ];

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return ListTile(
          leading: const Icon(Icons.search),
          title: Text(suggestion),
          onTap: () {
            _searchController.text = suggestion;
            _performSearch(suggestion);
          },
        );
      },
    );
  }
}
