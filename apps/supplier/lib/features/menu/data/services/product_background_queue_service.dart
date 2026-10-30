import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cook_connect_seller/core/network/api_exception.dart';
import 'package:cook_connect_seller/core/storage/token_storage_service.dart';
import 'package:cook_connect_seller/features/menu/data/models/seller_product_item.dart';
import 'package:cook_connect_seller/features/menu/data/models/product_dtos.dart';
import 'package:cook_connect_seller/features/menu/data/services/product_api_service.dart';
import 'package:cook_connect_seller/features/auth/data/services/seller_auth_service.dart';

/// Status of a background product upload/sync task
enum ProductTaskStatus {
  queued,
  uploading,
  submitting,
  completed,
  failed,
}

/// Represents an optimistic background product creation or update task.
class ProductUploadTask {
  final String id;
  final SellerProductItem product;
  final List<String> originalImages;
  final bool isUpdate;
  final String supplierId;
  ProductTaskStatus status;
  int currentImageIndex;
  int totalImages;
  String? errorMessage;
  final DateTime createdAt;
  DateTime? completedAt;

  ProductUploadTask({
    required this.id,
    required this.product,
    required this.originalImages,
    required this.isUpdate,
    required this.supplierId,
    this.status = ProductTaskStatus.queued,
    this.currentImageIndex = 0,
    this.totalImages = 0,
    this.errorMessage,
    DateTime? createdAt,
    this.completedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isProcessing =>
      status == ProductTaskStatus.queued ||
      status == ProductTaskStatus.uploading ||
      status == ProductTaskStatus.submitting;

  bool get isFailed => status == ProductTaskStatus.failed;
  bool get isCompleted => status == ProductTaskStatus.completed;
}

/// Singleton service managing optimistic background product uploads and server sync.
/// - Optimistic UI: Screen closes immediately without blocking user.
/// - Local Image Management: Users can freely add/edit/delete/reorder images without uploading to CDN upfront.
/// - Background Worker: Uploads local images to CDN & invokes create/update API in the background.
/// - Silent on success: No noisy notification if server returns OK.
/// - Immediate failure reporting: If anything fails, clearly reports the exact error and provides 1-tap re-edit.
class ProductBackgroundQueueService extends ChangeNotifier {
  ProductBackgroundQueueService._();
  static final ProductBackgroundQueueService _instance =
      ProductBackgroundQueueService._();
  static ProductBackgroundQueueService get instance => _instance;

  final List<ProductUploadTask> _tasks = [];
  final StreamController<ProductUploadTask> _taskCompletedController =
      StreamController<ProductUploadTask>.broadcast();
  final StreamController<ProductUploadTask> _taskFailedController =
      StreamController<ProductUploadTask>.broadcast();

  List<ProductUploadTask> get tasks => List.unmodifiable(_tasks);

  List<ProductUploadTask> get pendingTasks =>
      _tasks.where((t) => t.isProcessing).toList();

  List<ProductUploadTask> get failedTasks =>
      _tasks.where((t) => t.isFailed).toList();

  Stream<ProductUploadTask> get onTaskCompleted =>
      _taskCompletedController.stream;
  Stream<ProductUploadTask> get onTaskFailed => _taskFailedController.stream;

  /// Enqueues a product submission and starts background execution immediately.
  ProductUploadTask enqueue({
    required SellerProductItem product,
    required List<String> images,
    required bool isUpdate,
    required String supplierId,
    required ProductApiService apiService,
    required TokenStorageService tokenStorage,
    String? replaceTaskId,
  }) {
    if (replaceTaskId != null) {
      _tasks.removeWhere((t) => t.id == replaceTaskId);
    }

    final taskId = 'task_${DateTime.now().millisecondsSinceEpoch}_${product.id}';
    final task = ProductUploadTask(
      id: taskId,
      product: product,
      originalImages: List<String>.from(images),
      isUpdate: isUpdate,
      supplierId: supplierId,
      status: ProductTaskStatus.queued,
      totalImages: images.length,
    );

    _tasks.insert(0, task);
    notifyListeners();

    // Start background worker without awaiting (non-blocking)
    _processTask(task, apiService, tokenStorage);

    return task;
  }

  /// Processes a single task in the background:
  /// 1. Uploads local images to CDN
  /// 2. Invokes create/update API
  /// 3. Silently succeeds or reports exact failure
  Future<void> _processTask(
    ProductUploadTask task,
    ProductApiService apiService,
    TokenStorageService tokenStorage,
  ) async {
    try {
      // Resolve valid token:
      // Proactively refresh via /api/v1/auth/refresh if access token is expired
      AuthTokens? activeTokens = SellerAuthService.instance.tokens;
      activeTokens ??= await tokenStorage.getTokens();

      String? token;
      if (activeTokens != null) {
        if (!activeTokens.isAccessTokenExpired()) {
          token = activeTokens.accessToken;
        } else if (activeTokens.refreshToken.isNotEmpty &&
            !activeTokens.isRefreshTokenExpired()) {
          debugPrint('🔄 Access token expired in background product task. Calling /api/v1/auth/refresh to rotate tokens...');
          token = await SellerAuthService.instance.refreshAccessToken();
        } else {
          // Token is expired and cannot be refreshed
          token = null;
        }
      }

      if (token == null || token.isEmpty) {
        throw ApiException(
          statusCode: 401,
          errorCode: 'AUTH.TOKEN_EXPIRED',
          message: 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
        );
      }

      String getActiveToken() =>
          SellerAuthService.instance.tokens?.accessToken ?? token!;

      // Step 1: Upload local images
      task.status = ProductTaskStatus.uploading;
      notifyListeners();

      final uploadedImages = List<String>.from(task.originalImages);
      final localIndices = <int>[];
      for (int i = 0; i < uploadedImages.length; i++) {
        final img = uploadedImages[i];
        if (!img.startsWith('http://') && !img.startsWith('https://')) {
          localIndices.add(i);
        }
      }

      task.totalImages = localIndices.length;
      task.currentImageIndex = 0;

      for (int i = 0; i < localIndices.length; i++) {
        final idx = localIndices[i];
        task.currentImageIndex = i + 1;
        notifyListeners();

        try {
          final cdnUrl = await apiService.uploadMediaImage(
            token: getActiveToken(),
            imagePath: uploadedImages[idx],
            folder: 'cookconnect/products',
          );
          uploadedImages[idx] = cdnUrl;
        } catch (uploadErr) {
          debugPrint('❌ [BG_QUEUE] Image upload failed for image index $i: $uploadErr');
          if (uploadErr is ApiException && uploadErr.statusCode == 401) {
            rethrow;
          }
          throw ApiException(
            statusCode: 400,
            errorCode: 'MEDIA.UPLOAD_FAILED',
            message: 'Tải ảnh thứ ${i + 1} lên hệ thống thất bại: $uploadErr',
          );
        }
      }

      final productWithCdnImages = task.product.copyWith(
        images: uploadedImages,
        imageUrl: uploadedImages.isNotEmpty ? uploadedImages.first : null,
      );

      // Step 2: Call Server API
      task.status = ProductTaskStatus.submitting;
      notifyListeners();

      if (!task.isUpdate) {
        String effectiveSupplierId = task.supplierId;
        if (effectiveSupplierId.isEmpty) {
          try {
            final status = await SellerAuthService.instance.checkSupplierStatus();
            effectiveSupplierId = status?.supplier?.supplierId ?? '';
          } catch (_) {}
        }

        final createDto = CreateProductDto.fromSellerProductItem(
          productWithCdnImages,
          supplierId: effectiveSupplierId,
        );
        await apiService.createProduct(token: getActiveToken(), dto: createDto);
      } else {
        final updateDto =
            UpdateProductDto.fromSellerProductItem(productWithCdnImages);
        await apiService.updateProduct(
          token: getActiveToken(),
          productId: task.product.id,
          dto: updateDto,
        );
      }

      // Step 3: SUCCESS (Silent, no spam notification)
      task.status = ProductTaskStatus.completed;
      task.completedAt = DateTime.now();
      task.errorMessage = null;
      notifyListeners();
      _taskCompletedController.add(task);

    } catch (e, stackTrace) {
      debugPrint('Stack: $stackTrace');

      task.status = ProductTaskStatus.failed;
      task.errorMessage = _formatErrorMessage(e);
      notifyListeners();
      _taskFailedController.add(task);
    }
  }

  /// Retries a previously failed task.
  void retryTask(
    String taskId, {
    required ProductApiService apiService,
    required TokenStorageService tokenStorage,
  }) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      final task = _tasks[idx];
      task.status = ProductTaskStatus.queued;
      task.errorMessage = null;
      notifyListeners();
      _processTask(task, apiService, tokenStorage);
    }
  }

  /// Dismisses a failed task from queue
  void dismissFailedTask(String taskId) {
    _tasks.removeWhere((t) => t.id == taskId);
    notifyListeners();
  }

  /// Clears completed tasks
  void clearCompletedTasks() {
    _tasks.removeWhere((t) => t.isCompleted);
    notifyListeners();
  }

  String _formatErrorMessage(dynamic error) {
    if (error is ApiException) {
      if (error.statusCode == 400) {
        if (error.errorCode == 'PRODUCT.PRODUCT_NOT_OWNED') {
          return 'Bạn không có quyền sở hữu sản phẩm này.';
        } else if (error.errorCode == 'PRODUCT.PRODUCT_NOT_IN_REVIEWABLE_STATE') {
          return 'Sản phẩm không ở trạng thái hợp lệ để gửi xét duyệt.';
        } else if (error.errorCode == 'PRODUCT.SKU_ALREADY_EXISTS') {
          return 'Mã sản phẩm / SKU đã tồn tại trong gian hàng của bạn.';
        } else if (error.errorCode == 'MEDIA.FILE_REQUIRED' ||
            error.errorCode == 'MEDIA.UPLOAD_FAILED') {
          return error.message.isNotEmpty
              ? error.message
              : 'Tải ảnh lên hệ thống thất bại. Vui lòng kiểm tra lại ảnh.';
        } else if (error.errorCode == 'COMMON.VALIDATION_FAILED') {
          return 'Dữ liệu sản phẩm không hợp lệ: ${error.message}';
        }
        return error.message.isNotEmpty ? error.message : 'Yêu cầu không hợp lệ (${error.statusCode})';
      } else if (error.statusCode == 401) {
        return 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
      } else if (error.statusCode == 403) {
        return 'Bạn không có quyền đăng sản phẩm cho nhà cung cấp này.';
      } else if (error.statusCode == 404) {
        return 'Không tìm thấy dữ liệu nhà cung cấp hoặc sản phẩm.';
      } else if (error.statusCode == 429) {
        return 'Hệ thống đang bận. Vui lòng thử lại sau ít phút.';
      }
      return error.message.isNotEmpty ? error.message : 'Lỗi máy chủ (${error.statusCode})';
    }
    final str = error.toString();
    if (str.contains('SocketException') || str.contains('Connection refused') || str.contains('Network is unreachable')) {
      return 'Không có kết nối mạng. Vui lòng kiểm tra Internet của bạn.';
    }
    return str.replaceAll('Exception:', '').trim();
  }

  @override
  void dispose() {
    _taskCompletedController.close();
    _taskFailedController.close();
    super.dispose();
  }
}

