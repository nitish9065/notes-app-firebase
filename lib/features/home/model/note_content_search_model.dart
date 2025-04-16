import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final noteContentSearchProvider = StateNotifierProvider.autoDispose
  <NoteContentSearchNotifier, NoteContentSearchState>((ref) {
  return NoteContentSearchNotifier();
});

class NoteContentSearchState {
  final String query;
  final List<TextSpan> highlightedContent;
  final int currentMatchIndex;
  final int totalMatches;

  const NoteContentSearchState({
    this.query = '',
    this.highlightedContent = const [],
    this.currentMatchIndex = -1,
    this.totalMatches = 0,
  });

  NoteContentSearchState copyWith({
    String? query,
    List<TextSpan>? highlightedContent,
    int? currentMatchIndex,
    int? totalMatches,
  }) {
    return NoteContentSearchState(
      query: query ?? this.query,
      highlightedContent: highlightedContent ?? this.highlightedContent,
      currentMatchIndex: currentMatchIndex ?? this.currentMatchIndex,
      totalMatches: totalMatches ?? this.totalMatches,
    );
  }
}

class NoteContentSearchNotifier extends StateNotifier<NoteContentSearchState> {
  NoteContentSearchNotifier() : super(const NoteContentSearchState());

  void search(String query, String content) {
    if (query.isEmpty) {
      state = const NoteContentSearchState();
      return;
    }

    final matches = _findMatches(content, query);
    final highlightedContent = _highlightMatches(content, query, matches);
    
    state = NoteContentSearchState(
      query: query,
      highlightedContent: highlightedContent,
      currentMatchIndex: matches.isNotEmpty ? 0 : -1,
      totalMatches: matches.length,
    );
  }

  void navigateMatch(int direction) {
    if (state.totalMatches == 0) return;
    
    final newIndex = (state.currentMatchIndex + direction) % state.totalMatches;
    state = state.copyWith(currentMatchIndex: newIndex);
  }

  List<RegExpMatch> _findMatches(String content, String query) {
    final regex = RegExp(query, caseSensitive: false);
    return regex.allMatches(content).toList();
  }

  List<TextSpan> _highlightMatches(String content, String query, List<RegExpMatch> matches) {
    final spans = <TextSpan>[];
    int lastEnd = 0;

    for (final match in matches) {
      // Add non-matched text before the match
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: content.substring(lastEnd, match.start),
        ));
      }

      // Add highlighted match
      spans.add(TextSpan(
        text: content.substring(match.start, match.end),
        style: const TextStyle(
          backgroundColor: Colors.yellow,
          fontWeight: FontWeight.bold,
        ),
      ));

      lastEnd = match.end;
    }

    // Add remaining text after last match
    if (lastEnd < content.length) {
      spans.add(TextSpan(text: content.substring(lastEnd)));
    }

    return spans;
  }
}