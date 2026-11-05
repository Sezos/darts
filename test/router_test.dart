import 'package:darts/router.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('a profile link opens in the Friends tab', (tester) async {
    late BuildContext context;
    await tester.pumpWidget(
      Builder(
        builder: (c) {
          context = c;
          return const SizedBox();
        },
      ),
    );

    final matches = await router.routeInformationParser
        .parseRouteInformationWithDependencies(
          RouteInformation(uri: Uri.parse('/f/7K2QXP')),
          context,
        );

    expect(matches.uri.path, '/friends/f/7K2QXP');
    expect(matches.last.route.name, 'friend_profile');
  });
}
