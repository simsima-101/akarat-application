// lib/src/features/property/presentation/bloc/properties_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/api_service.dart';

import '../../data/models/project_model.dart'; // Adjust if your model path is different

part 'properties_event.dart';
part 'properties_state.dart';

class PropertiesBloc extends Bloc<PropertiesEvent, PropertiesState> {
  PropertiesBloc() : super(const PropertiesState.initial()) {
    on<LoadProperties>(_onLoadProperties);
    on<LoadMoreProperties>(_onLoadMoreProperties);
    on<RefreshProperties>(_onRefreshProperties);
  }

  Future<void> _onLoadProperties(
      LoadProperties event,
      Emitter<PropertiesState> emit,
      ) async {
    emit(state.copyWith(status: PropertiesStatus.loading));

    try {
      final uri = ApiService.buildUri(event.endpoint, query: {'page': '1'});
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final responseModel = ProjectResponseModel.fromJson(jsonData);
        final fetchedData = responseModel.data!;

        final projects = fetchedData.data ?? [];
        final hasMore = (fetchedData.meta?.currentPage ?? 1) < (fetchedData.meta?.lastPage ?? 1);

        emit(state.copyWith(
          status: PropertiesStatus.loaded,
          properties: projects,
          currentPage: 2,
          hasMore: hasMore,
          endpoint: event.endpoint,
        ));
      } else {
        emit(state.copyWith(
          status: PropertiesStatus.error,
          errorMessage: 'Failed to load properties',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: PropertiesStatus.error,
        errorMessage: 'Connection error',
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
      final uri = ApiService.buildUri(state.endpoint, query: {'page': '${state.currentPage}'});
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final responseModel = ProjectResponseModel.fromJson(jsonData);
        final fetchedData = responseModel.data!;

        final newProjects = fetchedData.data ?? [];
        final hasMore = (fetchedData.meta?.currentPage ?? 1) < (fetchedData.meta?.lastPage ?? 1);

        emit(state.copyWith(
          properties: [...state.properties, ...newProjects],
          currentPage: state.currentPage + 1,
          hasMore: hasMore,
          status: PropertiesStatus.loaded,
        ));
      } else {
        emit(state.copyWith(status: PropertiesStatus.loaded));
      }
    } catch (e) {
      emit(state.copyWith(status: PropertiesStatus.loaded));
    }
  }

  Future<void> _onRefreshProperties(
      RefreshProperties event,
      Emitter<PropertiesState> emit,
      ) async {
    add(LoadProperties(endpoint: state.endpoint));
  }
}