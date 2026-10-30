import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cook_connect_seller/features/menu/presentation/widgets/product_images_uploader.dart';

void main() {
  testWidgets('ProductImagesUploader displays empty hero cover card when no images', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    List<String> images = [];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProductImagesUploader(
              images: images,
              onImagesChanged: (updated) => images = updated,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Title and badge
    expect(find.text('Hình ảnh sản phẩm *'), findsOneWidget);
    expect(find.text('0/5 ảnh tối thiểu'), findsOneWidget);

    // Empty Hero Card
    expect(find.text('Tải lên ảnh bìa sản phẩm (Bắt buộc)'), findsOneWidget);
    expect(find.text('Chụp ảnh'), findsOneWidget);
    expect(find.text('Thư viện'), findsOneWidget);

    // Tips section header
    expect(find.text('Gợi ý 4 góc chụp thực phẩm chuẩn duyệt nhanh'), findsOneWidget);

    // Tap tips to expand
    await tester.tap(find.text('Gợi ý 4 góc chụp thực phẩm chuẩn duyệt nhanh'));
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate((w) => w is RichText && w.text.toPlainText().contains('Ảnh bìa toàn cảnh:')),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate((w) => w is RichText && w.text.toPlainText().contains('Cận cảnh chi tiết:')),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate((w) => w is RichText && w.text.toPlainText().contains('Bao bì & Tem nhãn:')),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate((w) => w is RichText && w.text.toPlainText().contains('Quy cách đóng gói:')),
      findsOneWidget,
    );
  });

  testWidgets('ProductImagesUploader displays hero cover and sub-gallery when images exist', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    List<String> images = [
      'https://example.com/cover.jpg',
      'https://example.com/sub1.jpg',
      'https://example.com/sub2.jpg',
    ];

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: ProductImagesUploader(
                  images: images,
                  onImagesChanged: (updated) {
                    setState(() {
                      images = updated;
                    });
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
    await tester.pumpAndSettle();

    // 3/5 images
    expect(find.text('3/5 ảnh tối thiểu'), findsOneWidget);
    expect(find.text('Ảnh bìa đại diện'), findsOneWidget);

    // Sub-gallery header
    expect(find.text('Ảnh chi tiết & góc chụp'), findsOneWidget);
    expect(find.text('2 ảnh'), findsOneWidget);

    // Index tags for sub images (#2, #3)
    expect(find.text('#2'), findsOneWidget);
    expect(find.text('#3'), findsOneWidget);

    // Tap "Làm bìa" on the second image (sub1)
    final setCoverButtons = find.text('Làm bìa');
    expect(setCoverButtons, findsNWidgets(2));

    await tester.tap(setCoverButtons.first);
    await tester.pumpAndSettle();

    // Now 'https://example.com/sub1.jpg' should be the cover (index 0)
    expect(images.first, 'https://example.com/sub1.jpg');
    expect(images[1], 'https://example.com/cover.jpg');
  });

  testWidgets('ProductImagesUploader shows full qualification badge when 5 or more images', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final images = [
      'https://example.com/1.jpg',
      'https://example.com/2.jpg',
      'https://example.com/3.jpg',
      'https://example.com/4.jpg',
      'https://example.com/5.jpg',
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProductImagesUploader(
              images: images,
              onImagesChanged: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('5/5 ảnh tối thiểu'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });

  testWidgets('Selecting 5 images at once updates list atomically without dropping images', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    List<String> images = [];

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: ProductImagesUploader(
                  images: images,
                  onImagesChanged: (updated) {
                    setState(() {
                      images = updated;
                    });
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('0/5 ảnh tối thiểu'), findsOneWidget);

    // Simulate batch pick of 5 images at once
    final uploaderState = tester.state(find.byType(ProductImagesUploader)) as dynamic;
    uploaderState.addImagesForTesting([
      'https://example.com/1.jpg',
      'https://example.com/2.jpg',
      'https://example.com/3.jpg',
      'https://example.com/4.jpg',
      'https://example.com/5.jpg',
    ]);
    await tester.pumpAndSettle();

    // Verify all 5 images are kept, none dropped, and sub-gallery displays properly
    expect(images.length, 5);
    expect(find.text('5/5 ảnh tối thiểu'), findsOneWidget);
    expect(find.text('#2'), findsOneWidget);
    expect(find.text('#3'), findsOneWidget);
    expect(find.text('#4'), findsOneWidget);
    expect(find.text('#5'), findsOneWidget);
  });
}
