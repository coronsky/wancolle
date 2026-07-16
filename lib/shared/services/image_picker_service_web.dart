import 'dart:async';
import 'dart:html' as html;
import 'dart:math' as math;

Future<String?> pickDogPhoto({
  bool captureFromCamera = false,
}) {
  final completer = Completer<String?>();
  final input = html.FileUploadInputElement()
    ..accept = 'image/*'
    ..multiple = false;

  if (captureFromCamera) {
    input.setAttribute('capture', 'environment');
  }

  input.onChange.first.then((_) async {
    final file = input.files?.isNotEmpty == true ? input.files!.first : null;
    if (file == null) {
      if (!completer.isCompleted) {
        completer.complete(null);
      }
      return;
    }

    try {
      final dataUrl = await _compressImageForWeb(file);
      if (!completer.isCompleted) {
        completer.complete(dataUrl);
      }
    } catch (_) {
      if (!completer.isCompleted) {
        completer.complete(null);
      }
    }
  });

  input.click();
  return completer.future;
}

Future<String> _compressImageForWeb(html.File file) async {
  final objectUrl = html.Url.createObjectUrl(file);
  final image = html.ImageElement();
  final loaded = Completer<void>();

  image.onLoad.first.then((_) => loaded.complete());
  image.onError.first.then((_) {
    if (!loaded.isCompleted) {
      loaded.completeError(StateError('Failed to load image'));
    }
  });
  image.src = objectUrl;

  await loaded.future;

  const maxDimension = 720.0;
  final width = image.naturalWidth.toDouble();
  final height = image.naturalHeight.toDouble();

  if (width <= 0 || height <= 0) {
    html.Url.revokeObjectUrl(objectUrl);
    throw StateError('Invalid image size');
  }

  final scale = math.min(1, maxDimension / math.max(width, height));
  final targetWidth = math.max(1, (width * scale).round());
  final targetHeight = math.max(1, (height * scale).round());

  final canvas = html.CanvasElement(
    width: targetWidth,
    height: targetHeight,
  );
  final context = canvas.context2D;
  context.imageSmoothingEnabled = true;
  context.imageSmoothingQuality = 'high';
  context.drawImageScaled(image, 0, 0, targetWidth.toDouble(), targetHeight.toDouble());

  html.Url.revokeObjectUrl(objectUrl);

  // JPEG keeps storage small enough for SharedPreferences/localStorage on web.
  return canvas.toDataUrl('image/jpeg', 0.60);
}
