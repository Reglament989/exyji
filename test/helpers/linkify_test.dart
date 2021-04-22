import 'package:exyji/helpers/linkify.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helper.dart';

void main() {
  group("Own linkify widget", () {
    testWidgets("Basic test linkify", (WidgetTester tester) async {
      final keyLink = Key("link");
      await tester.pumpWidget(QuickWidgetTest([
        LinkText(
            key: keyLink,
            text: "https://example.com Other text",
            onOpen: (link) async {
              expect(link.url, "https://example.com");
            }),
        LinkText(text: "", onOpen: (link) async {})
      ]));
      final linkFinder = find.byKey(keyLink);
      expect(linkFinder, findsOneWidget);

      await tester.tap(linkFinder);
    });
  });
}
