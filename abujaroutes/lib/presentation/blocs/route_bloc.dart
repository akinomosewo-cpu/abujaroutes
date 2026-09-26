import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/sample_routes.dart';
import '../../domain/models/transit_route.dart';
import '../../domain/route_filter.dart';

abstract class RouteEvent extends Equatable {
  const RouteEvent();
  @override
  List<Object?> get props => [];
}

class RoutesStarted extends RouteEvent {
  const RoutesStarted();
}

class RouteSearchChanged extends RouteEvent {
  final String query;
  const RouteSearchChanged(this.query);
  @override
  List<Object?> get props => [query];
}

class RouteModeFilterChanged extends RouteEvent {
  final TransitMode? mode;
  const RouteModeFilterChanged(this.mode);
  @override
  List<Object?> get props => [mode];
}

class RouteSubmitted extends RouteEvent {
  final TransitRoute route;
  const RouteSubmitted(this.route);
  @override
  List<Object?> get props => [route];
}

class RouteRemoved extends RouteEvent {
  final String id;
  const RouteRemoved(this.id);
  @override
  List<Object?> get props => [id];
}

class RouteState extends Equatable {
  final List<TransitRoute> allRoutes;
  final String query;
  final TransitMode? modeFilter;

  const RouteState({
    this.allRoutes = const [],
    this.query = '',
    this.modeFilter,
  });

  List<TransitRoute> get filteredRoutes =>
      filterRoutes(allRoutes, query: query, mode: modeFilter);

  RouteState copyWith({
    List<TransitRoute>? allRoutes,
    String? query,
    TransitMode? modeFilter,
    bool clearModeFilter = false,
  }) {
    return RouteState(
      allRoutes: allRoutes ?? this.allRoutes,
      query: query ?? this.query,
      modeFilter: clearModeFilter ? null : (modeFilter ?? this.modeFilter),
    );
  }

  @override
  List<Object?> get props => [allRoutes, query, modeFilter];
}

class RouteBloc extends Bloc<RouteEvent, RouteState> {
  RouteBloc() : super(const RouteState()) {
    on<RoutesStarted>((event, emit) {
      emit(state.copyWith(allRoutes: List.of(sampleRoutes)));
    });

    on<RouteSearchChanged>((event, emit) {
      emit(state.copyWith(query: event.query));
    });

    on<RouteModeFilterChanged>((event, emit) {
      if (event.mode == null) {
        emit(state.copyWith(clearModeFilter: true));
      } else {
        emit(state.copyWith(modeFilter: event.mode));
      }
    });

    on<RouteSubmitted>((event, emit) {
      emit(state.copyWith(allRoutes: [...state.allRoutes, event.route]));
    });

    on<RouteRemoved>((event, emit) {
      emit(state.copyWith(
        allRoutes: state.allRoutes.where((r) => r.id != event.id).toList(),
      ));
    });
  }
}
