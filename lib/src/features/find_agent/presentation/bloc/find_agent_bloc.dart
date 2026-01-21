// // lib/src/features/find_agent/presentation/bloc/find_agent_bloc.dart
//
// import 'dart:convert';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:http/http.dart' as http;
// import 'package:equatable/equatable.dart';
//
// import '../../../agency/data/models/agency_model.dart';
// import '../../../agency/data/models/agents_model.dart';
//
//
// part 'find_agent_event.dart';
// part 'find_agent_state.dart';
//
// const String kApiBase = 'akarat.com';
//
// final Map<String, String> serviceValueToId = {
//   'residential-for-sale': '1',
//   'residential-for-rent': '2',
//   'commercial-for-sale': '3',
//   'commercial-for-rent': '4',
// };
//
// class FindAgentBloc extends Bloc<FindAgentEvent, FindAgentState> {
//   int _agentPage = 1;
//   int _agencyPage = 1;
//
//   FindAgentBloc() : super(const FindAgentState()) {
//     on<InitializeFindAgent>(_onInitialize);
//     on<SearchAgents>(_onSearchAgents);
//     on<LoadMoreAgents>(_onLoadMoreAgents);
//     on<SearchAgencies>(_onSearchAgencies);
//     on<LoadMoreAgencies>(_onLoadMoreAgencies);
//     on<ResetFilters>(_onReset);
//
//     // Load initial data
//     add(InitializeFindAgent());
//   }
//
//   Future<void> _onInitialize(InitializeFindAgent event, Emitter<FindAgentState> emit) async {
//     _agentPage = 1;
//     _agencyPage = 1;
//     await Future.wait([
//       _loadAgents(emit, page: 1, isRefresh: true),
//       _loadAgencies(emit, page: 1, isRefresh: true),
//     ]);
//   }
//
//   Future<void> _onSearchAgents(SearchAgents event, Emitter<FindAgentState> emit) async {
//     _agentPage = 1;
//     emit(state.copyWith(
//       agentSearchQuery: event.query,
//       selectedAgentService: event.service,
//       selectedLanguage: event.language,
//       selectedNationality: event.nationality,
//       agents: [],
//       isLoadingAgents: true,
//     ));
//     await _loadAgents(emit, page: 1, isRefresh: true);
//   }
//
//   Future<void> _onLoadMoreAgents(LoadMoreAgents event, Emitter<FindAgentState> emit) async {
//     if (state.isLoadingMoreAgents || !state.hasMoreAgents) return;
//     emit(state.copyWith(isLoadingMoreAgents: true));
//     await _loadAgents(emit, page: _agentPage + 1, isRefresh: false);
//   }
//
//   Future<void> _onSearchAgencies(SearchAgencies event, Emitter<FindAgentState> emit) async {
//     _agencyPage = 1;
//     emit(state.copyWith(
//       agencySearchQuery: event.query,
//       selectedAgencyService: event.service,
//       agencies: [],
//       isLoadingAgencies: true,
//     ));
//     await _loadAgencies(emit, page: 1, isRefresh: true);
//   }
//
//   Future<void> _onLoadMoreAgencies(LoadMoreAgencies event, Emitter<FindAgentState> emit) async {
//     if (state.isLoadingMoreAgencies || !state.hasMoreAgencies) return;
//     emit(state.copyWith(isLoadingMoreAgencies: true));
//     await _loadAgencies(emit, page: _agencyPage + 1, isRefresh: false);
//   }
//
//   Future<void> _onReset(ResetFilters event, Emitter<FindAgentState> emit) async {
//     _agentPage = 1;
//     _agencyPage = 1;
//     emit(const FindAgentState());
//     await Future.wait([
//       _loadAgents(emit, page: 1, isRefresh: true),
//       _loadAgencies(emit, page: 1, isRefresh: true),
//     ]);
//   }
//
//   Future<void> _loadAgents(Emitter<FindAgentState> emit, {required int page, required bool isRefresh}) async {
//     final qp = <String, String>{
//       'page': page.toString(),
//       'per_page': '10',
//       if (state.agentSearchQuery.isNotEmpty) 'search': state.agentSearchQuery,
//       if (state.selectedAgentService != null)
//         'service_needed': serviceValueToId[state.selectedAgentService!]!,
//       if (state.selectedLanguage?.isNotEmpty == true) 'language': state.selectedLanguage!,
//       if (state.selectedNationality?.isNotEmpty == true) 'nationality': state.selectedNationality!,
//     };
//
//     final uri = Uri.https(kApiBase, '/api/agents', qp);
//
//     try {
//       final response = await http.get(uri);
//       if (response.statusCode != 200) return;
//
//       final json = jsonDecode(response.body);
//       final List data = json['data'] is List ? json['data'] : (json['data']?['data'] ?? []);
//       final newAgents = data.map((e) => AgentsModel.fromJson(e as Map<String, dynamic>)).toList();
//
//       if (isRefresh) {
//         emit(state.copyWith(agents: newAgents, isLoadingAgents: false));
//       } else {
//         emit(state.copyWith(agents: [...state.agents, ...newAgents], isLoadingMoreAgents: false));
//       }
//
//       _agentPage = page + 1;
//       emit(state.copyWith(hasMoreAgents: newAgents.length == 10));
//     } catch (e) {
//       emit(state.copyWith(isLoadingAgents: false, isLoadingMoreAgents: false));
//     }
//   }
//
//   Future<void> _loadAgencies(Emitter<FindAgentState> emit, {required int page, required bool isRefresh}) async {
//     final qp = <String, String>{
//       'page': page.toString(),
//       'per_page': '10',
//       if (state.agencySearchQuery.isNotEmpty) 'search': state.agencySearchQuery,
//       if (state.selectedAgencyService != null)
//         'service_needed': serviceValueToId[state.selectedAgencyService!]!,
//     };
//
//     final uri = Uri.https(kApiBase, '/api/companies', qp);
//
//     try {
//       final response = await http.get(uri);
//       if (response.statusCode != 200) return;
//
//       final json = jsonDecode(response.body);
//       final List data = json['data'] is List ? json['data'] : (json['data']?['data'] ?? []);
//       final newAgencies = data.map((e) => Agency.fromJson(e as Map<String, dynamic>)).toList();
//
//       if (isRefresh) {
//         emit(state.copyWith(agencies: newAgencies, isLoadingAgencies: false));
//       } else {
//         emit(state.copyWith(agencies: [...state.agencies, ...newAgencies], isLoadingMoreAgencies: false));
//       }
//
//       _agencyPage = page + 1;
//       emit(state.copyWith(hasMoreAgencies: newAgencies.length == 10));
//     } catch (e) {
//       emit(state.copyWith(isLoadingAgencies: false, isLoadingMoreAgencies: false));
//     }
//   }
// }