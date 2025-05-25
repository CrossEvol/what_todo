part of 'search_bloc.dart';

enum FilteredField {
  id,
  title,
  project,
  dueDate,
  status,
  priority,
  order,
}

enum SearchResultsOrder {
  asc,
  desc,
}

sealed class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

final class SearchInitial extends SearchState {}

final class SearchLoadingState extends SearchState {}

final class SearchResultsState extends SearchState {
  final String keyword;
  final bool searchInTitle;
  final bool searchInComment;
  final List<Task> tasks;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final FilteredField? filteredField;
  final SearchResultsOrder? order;

  const SearchResultsState({
    required this.keyword,
    required this.searchInTitle,
    required this.searchInComment,
    required this.tasks,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    this.filteredField,
    this.order,
  });

  @override
  List<Object?> get props => [
        keyword,
        searchInTitle,
        searchInComment,
        tasks,
        currentPage,
        totalPages,
        totalItems,
        filteredField,
        order,
      ];
}

final class SearchErrorState extends SearchState {
  final String error;

  const SearchErrorState(this.error);

  @override
  List<Object> get props => [error];
}
