import 'dart:io' show File;
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

/// Content type inferred from the file extension.
enum PickedFileType {
  /// Image file (jpg, png, gif, webp, etc.).
  image,

  /// Video file (mp4, mov, avi, etc.).
  video,

  /// Audio file (mp3, wav, aac, etc.).
  audio,

  /// Document file (pdf, doc, xls, etc.).
  document,

  /// Unrecognized or missing extension.
  other;

  /// Infers the type from [extension] (without leading dot, case-insensitive).
  ///
  /// Returns [other] when [extension] is null or unrecognized.
  static PickedFileType fromExtension(String? extension) {
    if (extension == null) return other;
    final ext = extension.toLowerCase();
    if (_supportExtensions['image']!.contains(ext)) return image;
    if (_supportExtensions['video']!.contains(ext)) return video;
    if (_supportExtensions['audio']!.contains(ext)) return audio;
    if (_supportExtensions['document']!.contains(ext)) return document;
    return other;
  }

  static const Map<String, Set<String>> _supportExtensions = {
    'image': {'jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'heic', 'heif', 'tiff'},
    'video': {'mp4', 'mov', 'avi', 'mkv', 'webm', 'm4v', '3gp', 'flv'},
    'audio': {'mp3', 'aac', 'wav', 'ogg', 'm4a', 'flac', 'wma', 'opus', 'amr'},
    'document': {'pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt', 'csv', 'rtf', 'odt', 'ods'},
  };
}

/// Unified representation of a file picked from camera, gallery, or file system.
///
/// Wraps results from both `image_picker` ([XFile]) and `file_picker`
/// ([PlatformFile]) into a single immutable model.
///
/// Usage:
/// ```dart
/// // from image_picker
/// final xFile = await ImagePicker().pickImage(source: ImageSource.gallery);
/// final picked = PickedFile.fromXFile(xFile!, size: await xFile.length());
///
/// // from file_picker
/// final result = await FilePicker.platform.pickFiles();
/// final picked = PickedFile.fromPlatformFile(result!.files.single);
/// ```
class PickedFile extends Equatable {
  /// File name including extension (e.g. `"photo.jpg"`).
  final String name;

  /// Absolute file-system path. `null` on web where only [bytes] is available.
  final String? path;

  /// File size in bytes. `null` when not pre-resolved (e.g. from [fromXFile]
  /// without passing [size] — call `XFile.length()` before constructing).
  final int? size;

  /// Extension without leading dot (e.g. `"jpg"`, `"pdf"`). `null` when the
  /// file has no extension.
  final String? extension;

  /// Inferred content category based on [extension].
  final PickedFileType type;

  /// In-memory bytes. Populated by `file_picker` on web, or when the caller
  /// pre-loads them. Use [readBytes] to load on demand from [path].
  final Uint8List? bytes;

  /// Creates a [PickedFile] with the given fields.
  const PickedFile({
    required this.name,
    this.path,
    this.size,
    this.extension,
    required this.type,
    this.bytes,
  });

  // FACTORIES

  /// Creates a [PickedFile] from an [XFile] (image_picker result).
  ///
  /// [size] must be supplied by the caller — call `await file.length()` before
  /// constructing because factory constructors cannot be async.
  factory PickedFile.fromXFile(XFile file, {int? size}) {
    final ext = file.name.contains('.')
        ? file.name.split('.').last
        : null;
    return PickedFile(
      name: file.name,
      path: file.path.isNotEmpty ? file.path : null,
      size: size,
      extension: ext,
      type: PickedFileType.fromExtension(ext),
    );
  }

  /// Creates a [PickedFile] from a [PlatformFile] (file_picker result).
  factory PickedFile.fromPlatformFile(PlatformFile file) => PickedFile(
    name: file.name,
    path: file.path,
    size: file.size,
    extension: file.extension,
    type: PickedFileType.fromExtension(file.extension),
    bytes: file.bytes,
  );

  // METHODS

  /// Returns a copy with the specified fields replaced.
  PickedFile copyWith({
    String? name,
    String? path,
    int? size,
    String? extension,
    PickedFileType? type,
    Uint8List? bytes,
  }) => PickedFile(
    name: name ?? this.name,
    path: path ?? this.path,
    size: size ?? this.size,
    extension: extension ?? this.extension,
    type: type ?? this.type,
    bytes: bytes ?? this.bytes,
  );

  /// Reads the file content into memory.
  ///
  /// Returns [bytes] if already loaded, otherwise reads from [path].
  /// Returns `null` when neither is available.
  Future<Uint8List?> readBytes() async {
    if (bytes != null) return bytes;
    if (path != null) return File(path!).readAsBytes();
    return null;
  }

  /// Converts back to an [XFile] using [path].
  ///
  /// Returns `null` when [path] is unavailable (e.g. web-picked files).
  XFile? toXFile() => path != null ? XFile(path!) : null;

  // GETTERS

  /// Whether [type] is [PickedFileType.image].
  bool get isImage => type == PickedFileType.image;

  /// Whether [type] is [PickedFileType.video].
  bool get isVideo => type == PickedFileType.video;

  /// Whether [type] is [PickedFileType.audio].
  bool get isAudio => type == PickedFileType.audio;

  /// Whether [type] is [PickedFileType.document].
  bool get isDocument => type == PickedFileType.document;

  /// Properties compared by [Equatable] for value equality.
  @override
  List<Object?> get props => [name, path, size, extension, type, bytes];

  /// Returns a debug-friendly string representation of this [PickedFile].
  @override
  String toString() =>
      'PickedFile(name: $name, type: $type, size: $size, path: $path)';
}
