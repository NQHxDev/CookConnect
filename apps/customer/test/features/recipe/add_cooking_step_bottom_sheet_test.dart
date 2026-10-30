import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cookconnect/features/recipe/data/models/recipe.dart';
import 'package:cookconnect/features/recipe/presentation/widgets/add_cooking_step_bottom_sheet.dart';

void main() {
  testWidgets('AddCookingStepBottomSheet displays correctly and supports quick suggestions',
      (WidgetTester tester) async {
    CookingStep? savedStep;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                savedStep = await AddCookingStepBottomSheet.show(
                  context,
                  stepNumber: 1,
                );
              },
              child: const Text('Open Step Sheet'),
            ),
          ),
        ),
      ),
    );

    // Open sheet
    await tester.tap(find.text('Open Step Sheet'));
    await tester.pumpAndSettle();

    // Verify header elements
    expect(find.text('Thêm bước nấu'), findsOneWidget);
    expect(find.text('Bước 1'), findsOneWidget);
    expect(find.text('Gợi ý nhanh tên bước:'), findsOneWidget);
    expect(find.text('Tiêu đề bước nấu'), findsOneWidget);
    expect(find.text('Chi tiết thao tác thực hiện'), findsOneWidget);
    expect(find.text('Thời gian ước tính'), findsOneWidget);

    // Tap quick suggestion chip: "Phi thơm hành tỏi"
    await tester.tap(find.text('Phi thơm hành tỏi'));
    await tester.pumpAndSettle();

    // Verify title textfield updated
    expect(find.text('Phi thơm hành tỏi'), findsWidgets);

    // Enter instructions
    final descField = find.byType(TextField).at(1);
    await tester.enterText(
      descField,
      'Cho hành tỏi vào chảo dầu nóng, đảo đều trên lửa vừa cho đến khi vàng thơm.',
    );
    await tester.pumpAndSettle();

    // Select quick duration pill '10 p'
    await tester.ensureVisible(find.text('10 p'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('10 p'));
    await tester.pumpAndSettle();
    expect(find.text('10 phút'), findsOneWidget);

    // Enter chef tip
    final tipField = find.byType(TextField).at(2);
    await tester.ensureVisible(tipField);
    await tester.pumpAndSettle();
    await tester.enterText(
      tipField,
      'Không để lửa quá lớn tránh làm tỏi bị cháy đắng.',
    );
    await tester.pumpAndSettle();

    // Tap "Lưu bước nấu"
    await tester.tap(find.text('Lưu bước nấu'));
    await tester.pumpAndSettle();

    // Verify returned CookingStep
    expect(savedStep, isNotNull);
    expect(savedStep!.stepNumber, 1);
    expect(savedStep!.title, 'Phi thơm hành tỏi');
    expect(
      savedStep!.description,
      'Cho hành tỏi vào chảo dầu nóng, đảo đều trên lửa vừa cho đến khi vàng thơm.',
    );
    expect(savedStep!.durationMinutes, 10);
    expect(
      savedStep!.tip,
      'Không để lửa quá lớn tránh làm tỏi bị cháy đắng.',
    );
  });

  testWidgets('AddCookingStepBottomSheet validates empty title and description',
      (WidgetTester tester) async {
    CookingStep? savedStep;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                savedStep = await AddCookingStepBottomSheet.show(
                  context,
                  stepNumber: 2,
                );
              },
              child: const Text('Open Step Sheet'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Step Sheet'));
    await tester.pumpAndSettle();

    // Tap save without entering anything
    await tester.tap(find.text('Lưu bước nấu'));
    await tester.pumpAndSettle();

    // Expect warning snackbar for title
    expect(
      find.text('Vui lòng nhập hoặc chọn tiêu đề cho bước nấu!'),
      findsOneWidget,
    );
    expect(savedStep, isNull);

    // Enter title only
    final titleField = find.byType(TextField).first;
    await tester.enterText(titleField, 'Xào rau muống');
    await tester.pumpAndSettle();

    // Tap save without entering description
    await tester.tap(find.text('Lưu bước nấu'));
    await tester.pumpAndSettle();

    expect(
      find.text('Vui lòng nhập chi tiết thao tác thực hiện!'),
      findsOneWidget,
    );
    expect(savedStep, isNull);
  });

  testWidgets('AddCookingStepBottomSheet supports editing an existing step',
      (WidgetTester tester) async {
    const existingStep = CookingStep(
      stepNumber: 3,
      title: 'Hầm canh sườn',
      description: 'Ninh nhỏ lửa trong 45 phút cho sườn mềm ngọt.',
      tip: 'Thường xuyên hớt bọt để nước canh trong.',
      durationMinutes: 45,
    );

    CookingStep? updatedStep;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                updatedStep = await AddCookingStepBottomSheet.show(
                  context,
                  editItem: existingStep,
                  stepNumber: 3,
                );
              },
              child: const Text('Edit Step'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Edit Step'));
    await tester.pumpAndSettle();

    expect(find.text('Chỉnh sửa bước 3'), findsOneWidget);
    expect(find.text('Hầm canh sườn'), findsOneWidget);
    expect(find.text('Ninh nhỏ lửa trong 45 phút cho sườn mềm ngọt.'), findsOneWidget);
    expect(find.text('45 phút'), findsOneWidget);
    expect(find.text('Lưu thay đổi'), findsOneWidget);

    // Update title
    final titleField = find.byType(TextField).first;
    await tester.enterText(titleField, 'Hầm canh sườn ngô ngọt');
    await tester.pumpAndSettle();

    // Save changes
    await tester.tap(find.text('Lưu thay đổi'));
    await tester.pumpAndSettle();

    expect(updatedStep, isNotNull);
    expect(updatedStep!.stepNumber, 3);
    expect(updatedStep!.title, 'Hầm canh sườn ngô ngọt');
    expect(updatedStep!.durationMinutes, 45);
    expect(updatedStep!.tip, 'Thường xuyên hớt bọt để nước canh trong.');
  });
}
