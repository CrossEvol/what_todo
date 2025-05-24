import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_app/dao/search_db.dart';
import 'package:flutter_app/utils/logger_util.dart';

import '../../pages/tasks/models/task.dart';

part 'search_event.dart';

part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchDB _searchDB;
  final ILogger _logger = ILogger();

  SearchBloc(this._searchDB) : super(SearchInitial()) {
    on<SearchTasksEvent>(_onSearchTasks);
    on<ResetSearchEvent>(_onResetSearch);
    on<UpdateSortFieldEvent>(_onUpdateSortField);
    on<UpdateSortOrderEvent>(_onUpdateSortOrder);
    on<NavigateToPageEvent>(_onNavigateToPage);
  }

  Future<void> _onSearchTasks(
      SearchTasksEvent event, Emitter<SearchState> emit) async {
    try {
      emit(SearchLoadingState());

      final result = await _searchDB.searchTasks(
        keyword: event.keyword,
        searchInTitle: event.searchInTitle,
        searchInComment: event.searchInComment,
        filteredField: event.filteredField,
        order: event.order,
        page: event.page,
        itemsPerPage: 10,
      );

      emit(SearchResultsState(
        keyword: event.keyword,
        searchInTitle: event.searchInTitle,
        searchInComment: event.searchInComment,
        tasks: result.tasks,
        currentPage: result.currentPage,
        totalPages: result.totalPages,
        totalItems: result.totalItems,
        filteredField: event.filteredField,
        order: event.order,
      ));
    } catch (e) {
      _logger.error(e, message: 'Error searching tasks');
      emit(SearchErrorState('Failed to search tasks: ${e.toString()}'));
    }
  }

  void _onResetSearch(ResetSearchEvent event, Emitter<SearchState> emit) {
    emit(SearchInitial());
  }

  Future<void> _onUpdateSortField(
      UpdateSortFieldEvent event, Emitter<SearchState> emit) async {
    final currentState = state;
    if (currentState is SearchResultsState) {
      await _updateSearchWithNewParams(
        emit: emit,
        keyword: currentState.keyword,
        searchInTitle: currentState.searchInTitle,
        searchInComment: currentState.searchInComment,
        filteredField: event.filteredField,
        order: currentState.order,
        page: currentState.currentPage,
      );
    }
  }

  Future<void> _onUpdateSortOrder(
      UpdateSortOrderEvent event, Emitter<SearchState> emit) async {
    final currentState = state;
    if (currentState is SearchResultsState) {
      await _updateSearchWithNewParams(
        emit: emit,
        keyword: currentState.keyword,
        searchInTitle: currentState.searchInTitle,
        searchInComment: currentState.searchInComment,
        filteredField: currentState.filteredField,
        order: event.order,
        page: currentState.currentPage,
      );
    }
  }

  Future<void> _onNavigateToPage(
      NavigateToPageEvent event, Emitter<SearchState> emit) async {
    final currentState = state;
    if (currentState is SearchResultsState) {
      await _updateSearchWithNewParams(
        emit: emit,
        keyword: currentState.keyword,
        searchInTitle: currentState.searchInTitle,
        searchInComment: currentState.searchInComment,
        filteredField: currentState.filteredField,
        order: currentState.order,
        page: event.page,
      );
    }
  }

  Future<void> _updateSearchWithNewParams({
    required Emitter<SearchState> emit,
    required String keyword,
    required bool searchInTitle,
    required bool searchInComment,
    required FilteredField? filteredField,
    required Order? order,
    required int page,
  }) async {
    add(SearchTasksEvent(
      keyword: keyword,
      searchInTitle: searchInTitle,
      searchInComment: searchInComment,
      filteredField: filteredField,
      order: order,
      page: page,
    ));
  }
}
