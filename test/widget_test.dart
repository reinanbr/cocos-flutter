import 'package:flutter_test/flutter_test.dart';

import 'package:cocos_flutter/main.dart';

void main() {
  testWidgets('COCOS home screen loads', (WidgetTester tester) async {
    await tester.pumpWidget(const CocosApp());
    await tester.pumpAndSettle();

    expect(find.text('Bem-vindo ao COCOS'), findsOneWidget);
    expect(find.text('O que deseja fazer?'), findsOneWidget);
  });
}
