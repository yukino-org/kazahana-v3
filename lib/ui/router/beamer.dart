import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import '../pages/home/view.dart';
import '../pages/search/view.dart';
import 'routes.dart';

export 'package:beamer/beamer.dart';

typedef BeamerRouteBuilderFn = dynamic Function(
  BuildContext,
  BeamState,
  Object?,
);

final BeamerParser routeInformationParser = BeamerParser();

final BeamerDelegate routerDelegate = BeamerDelegate(
  locationBuilder: RoutesLocationBuilder(
    routes: <Pattern, BeamerRouteBuilderFn>{
      RouteNames.home: (final _, final __, final ___) => const HomePage(),
      RouteNames.search: (final _, final __, final ___) => const SearchPage(),
    },
  ),
);
