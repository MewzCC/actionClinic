import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:procrastination_treatment_app/app.dart';

void main() {
  testWidgets('runs core action clinic flow', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    await tester.pumpWidget(const ActionClinicApp());
    await tester.pump();

    expect(find.text('行动治疗所'), findsOneWidget);
    expect(find.text('还没有任务'), findsOneWidget);
    expect(find.text('先添加一个今天要完成的行动'), findsOneWidget);
    expect(find.text('今日任务'), findsWidgets);

    await tester.tap(find.text('计划'));
    await tester.pump(const Duration(milliseconds: 320));

    expect(find.text('行动计划'), findsOneWidget);
    expect(find.text('创建并开始监督'), findsOneWidget);

    await tester.ensureVisible(find.text('创建并开始监督'));
    await tester.pump();
    await tester.tap(find.text('创建并开始监督'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('监督已开启'), findsOneWidget);
    await tester.tap(find.text('马上开始'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('专注执行中'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    expect(find.text('暂停监督'), findsOneWidget);

    await tester.ensureVisible(
      find.byKey(const ValueKey('trigger-punishment-button')),
    );
    await tester.pump();
    final triggerButton = tester.widget<OutlinedButton>(
      find.byKey(const ValueKey('trigger-punishment-button')),
    );
    triggerButton.onPressed!();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('你又拖延了！'), findsOneWidget);

    await tester.tap(find.text('我马上去做'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('专注执行中'), findsOneWidget);

    await tester.tap(find.text('我的'));
    await tester.pump(const Duration(milliseconds: 320));
    expect(find.text('桌面小组件预览'), findsOneWidget);
    expect(find.text('App 内悬浮小窗'), findsOneWidget);

    await tester.binding.setSurfaceSize(null);
  });
}
