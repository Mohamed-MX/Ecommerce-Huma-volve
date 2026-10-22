import 'package:flutter_test/flutter_test.dart';
import 'package:ecommerce_app_huma_volve/main.dart';
import 'package:ecommerce_app_huma_volve/features/splash/screens/splash_screen.dart';

void main() {
  testWidgets('App launches with SplashScreen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(SplashScreen), findsOneWidget);
    // Settle the 3-second splash timer
    await tester.pumpAndSettle(const Duration(seconds: 4));
  });
}
