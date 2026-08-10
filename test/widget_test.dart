import 'package:flutter_test/flutter_test.dart';

import 'package:pixel_weather_forecast/main.dart';

void main() {
  testWidgets('App boots to the splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const PixelWeatherRoot());
    await tester.pump();

    expect(find.text('PIXEL WEATHER'), findsOneWidget);
  });
}
