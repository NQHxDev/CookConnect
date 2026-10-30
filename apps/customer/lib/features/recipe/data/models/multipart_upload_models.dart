library;

/// DTOs for 3-step Cloudflare R2 multipart video upload workflow

/// Step 1 Request: Initiate multipart upload
class InitiateMultipartUploadDto {
  final String fileName;
  final String mimeType;
  final int partsCount;
  final int? fileSize;
  final String? folder;

  const InitiateMultipartUploadDto({
    required this.fileName,
    required this.mimeType,
    required this.partsCount,
    this.fileSize,
    this.folder,
  });

  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'mimeType': mimeType,
      'partsCount': partsCount,
      if (fileSize != null) 'fileSize': fileSize,
      if (folder != null && folder!.isNotEmpty) 'folder': folder,
    };
  }
}

/// Presigned Part URL item returned in Step 1 response
class MultipartPartUrlDto {
  final int partNumber;
  final String uploadUrl;

  const MultipartPartUrlDto({
    required this.partNumber,
    required this.uploadUrl,
  });

  factory MultipartPartUrlDto.fromJson(Map<String, dynamic> json) {
    return MultipartPartUrlDto(
      partNumber: (json['partNumber'] as num?)?.toInt() ?? 1,
      uploadUrl: json['uploadUrl']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'partNumber': partNumber, 'uploadUrl': uploadUrl};
  }
}

/// Step 1 Response: Initiate multipart upload response
class InitiateMultipartUploadResponseDto {
  final String mediaId;
  final String uploadId;
  final String? key;
  final String? publicUrl;
  final List<MultipartPartUrlDto> parts;

  const InitiateMultipartUploadResponseDto({
    required this.mediaId,
    required this.uploadId,
    this.key,
    this.publicUrl,
    required this.parts,
  });

  factory InitiateMultipartUploadResponseDto.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawParts = json['parts'] as List? ?? [];
    return InitiateMultipartUploadResponseDto(
      mediaId: json['mediaId']?.toString() ?? '',
      uploadId: json['uploadId']?.toString() ?? '',
      key: json['key']?.toString(),
      publicUrl: json['publicUrl']?.toString(),
      parts: rawParts
          .map((p) => MultipartPartUrlDto.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Step 2 Result / Step 3 Input: Completed Part with ETag
class CompletedPartDto {
  final int partNumber;
  final String etag;

  const CompletedPartDto({required this.partNumber, required this.etag});

  Map<String, dynamic> toJson() {
    // Provide both 'etag' and 'eTag' to ensure compatibility with backend serializers
    return {'partNumber': partNumber, 'etag': etag, 'eTag': etag};
  }

  factory CompletedPartDto.fromJson(Map<String, dynamic> json) {
    return CompletedPartDto(
      partNumber: (json['partNumber'] as num?)?.toInt() ?? 1,
      etag: json['etag']?.toString() ?? json['eTag']?.toString() ?? '',
    );
  }
}

/// Step 3 Request: Complete multipart upload
class CompleteMultipartUploadDto {
  final String mediaId;
  final String uploadId;
  final List<CompletedPartDto> parts;

  const CompleteMultipartUploadDto({
    required this.mediaId,
    required this.uploadId,
    required this.parts,
  });

  Map<String, dynamic> toJson() {
    return {
      'mediaId': mediaId,
      'uploadId': uploadId,
      'parts': parts.map((p) => p.toJson()).toList(),
    };
  }
}

/// Step 3 Response: Finalized media entity in PROCESSING state
class CompleteMultipartUploadResponseDto {
  final String id;
  final String url;
  final String status;
  final String? key;
  final String? mimeType;
  final int? size;
  final Map<String, dynamic>? metadata;

  const CompleteMultipartUploadResponseDto({
    required this.id,
    required this.url,
    required this.status,
    this.key,
    this.mimeType,
    this.size,
    this.metadata,
  });

  factory CompleteMultipartUploadResponseDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompleteMultipartUploadResponseDto(
      id: json['id']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      status: json['status']?.toString() ?? 'PROCESSING',
      key: json['key']?.toString(),
      mimeType: json['mimeType']?.toString(),
      size: json['size'] is num ? (json['size'] as num).toInt() : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}
