import 'package:flutter_test/flutter_test.dart';
import 'package:internee_lms/app/app.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const InterneeLmsApp());
    await tester.pumpAndSettle(const Duration(seconds: 5));
  });
}
