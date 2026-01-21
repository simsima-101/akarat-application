// // lib/src/features/find_agent/presentation/bloc/find_agent_event.dart
//
// part of 'find_agent_bloc.dart';
//
// import 'package:equatable/equatable.dart';
//
// abstract class FindAgentEvent extends Equatable {
//   const FindAgentEvent();
//
//   @override
//   List<Object?> get props => [];
// }
//
// class InitializeFindAgent extends FindAgentEvent {}
//
// class LoadMoreAgents extends FindAgentEvent {}
//
// class LoadMoreAgencies extends FindAgentEvent {}
//
// class SearchAgents extends FindAgentEvent {
//   final String query;
//   final String? service;
//   final String? language;
//   final String? nationality;
//
//   const SearchAgents({
//     required this.query,
//     this.service,
//     this.language,
//     this.nationality,
//   });
//
//   @override
//   List<Object?> get props => [query, service, language, nationality];
// }
//
// class SearchAgencies extends FindAgentEvent {
//   final String query;
//   final String? service;
//
//   const SearchAgencies({
//     required this.query,
//     this.service,
//   });
//
//   @override
//   List<Object?> get props => [query, service];
// }
//
// class ResetFilters extends FindAgentEvent {}