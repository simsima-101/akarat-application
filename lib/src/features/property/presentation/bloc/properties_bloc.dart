// lib/src/features/property/presentation/bloc/properties_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/property_repository.dart';
import '../../data/models/project_model.dart';

part 'properties_event.dart';
part 'properties_state.dart';

class PropertiesBloc extends Bloc<PropertiesEvent, PropertiesState> {
  final PropertyRepository repository;

  PropertiesBloc({required this.repository})
      : super(const PropertiesState.initial()) {
    on<LoadProperties>(_onLoadProperties);
    on<LoadMoreProperties>(_onLoadMoreProperties);
    on<RefreshProperties>(_onRefreshProperties);
    on<ChangeSort>(_onChangeSort);
  }

  Future<void> _onLoadProperties(
      LoadProperties event,
      Emitter<PropertiesState> emit,
      ) async {
    emit(state.copyWith(status: PropertiesStatus.loading));

    try {
      final result = await repository.fetchProperties(
        endpoint: event.endpoint,
        page: 1,
        sortBy: null, // or pass default sort if you have one
      );

      final newData = result.data!;
      final projects = newData.data ?? [];
      final hasMore = (newData.meta?.currentPage ?? 1) < (newData.meta?.lastPage ?? 1);
      final total = newData.meta?.total ?? 0;

      emit(state.copyWith(
        status: PropertiesStatus.loaded,
        properties: projects,
        currentPage: 2,
        hasMore: hasMore,
        endpoint: event.endpoint,
        totalProperties: total,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PropertiesStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadMoreProperties(
      LoadMoreProperties event,
      Emitter<PropertiesState> emit,
      ) async {
    if (!state.hasMore || state.status == PropertiesStatus.loadingMore) return;

    emit(state.copyWith(status: PropertiesStatus.loadingMore));

    try {
      final result = await repository.fetchProperties(
        endpoint: state.endpoint,
        page: state.currentPage,
        sortBy: null, // sort stays the same during load more
      );

      final newData = result.data!;
      final newProjects = newData.data ?? [];
      final hasMore = (newData.meta?.currentPage ?? 1) < (newData.meta?.lastPage ?? 1);

      emit(state.copyWith(
        properties: [...state.properties, ...newProjects],
        currentPage: state.currentPage + 1,
        hasMore: hasMore,
        status: PropertiesStatus.loaded,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PropertiesStatus.loaded, // or error if you prefer
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onChangeSort(
      ChangeSort event,
      Emitter<PropertiesState> emit,
      ) async {
    // Clear old data for better UX during sort change
    emit(state.copyWith(
      status: PropertiesStatus.loading,
      properties: const [],
      currentPage: 1,
      hasMore: true,
    ));

    try {
      final result = await repository.fetchProperties(
        endpoint: state.endpoint,
        page: 1,
        sortBy: event.sortBy,
      );

      final newData = result.data!;
      final projects = newData.data ?? [];
      final hasMore = (newData.meta?.currentPage ?? 1) < (newData.meta?.lastPage ?? 1);

      emit(state.copyWith(
        status: PropertiesStatus.loaded,
        properties: projects,
        currentPage: 2,
        hasMore: hasMore,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PropertiesStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRefreshProperties(
      RefreshProperties event,
      Emitter<PropertiesState> emit,
      ) async {
    // Reset pagination and reload
    emit(state.copyWith(
      status: PropertiesStatus.loading,
      properties: const [],
      currentPage: 1,
      hasMore: true,
    ));

    add(LoadProperties(endpoint: state.endpoint));
  }
}