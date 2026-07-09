import 'package:flutter_test/flutter_test.dart';

import 'package:gorodki/main.dart';

void main() {
  testWidgets('app builds and shows the HUD', (tester) async {
    await tester.pumpWidget(const GorodkiApp());
    await tester.pump();
    expect(find.textContaining('Throws:'), findsOneWidget);
  });
}
