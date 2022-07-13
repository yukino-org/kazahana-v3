import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import '../pages/home/view.dart';
import 'routes.dart';

typedef BeamerRouteBuilderFn = dynamic Function(
  BuildContext,
  BeamState,
  Object?,
);

final BeamerParser routeInformationParser = BeamerParser();

final BeamerDelegate routerDelegate = BeamerDelegate(
  locationBuilder: RoutesLocationBuilder(
    routes: <Pattern, BeamerRouteBuilderFn>{
      RouteNames.home: (
        final BuildContext context,
        final BeamState state,
        final Object? _,
      ) =>
          const HomePage(),
    },
  ),
);
