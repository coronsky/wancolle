import 'dart:async';
import 'dart:html' as html;
import 'dart:math' as math;

Future<String> optimizeStoredPhoto(String photoPath) async {
  if (!photoPath.startsWith('data:image/')) {
    return photoPath;
  }

  // Leave already-small images untouched.
  if (photoPath.length < 100000) {
    return photoPath;
  }

  try {
    return await _compressDataUrl(photoPath);
  } catch (_) {
    return photoPath;
  }
}

Future<String> _compressDataUrl(String dataUrl) async {
  final image = html.ImageElement();
  final loaded = Completer<void>();

  image.onLoad.first.then((_) => loaded.complete());
  image.onError.first.then((_) {
    if (!loaded.isCompleted) {
      loaded.completeError(StateError('Failed to load data image'));
    }
  });
  image.src = dataUrl;

  await loaded.future;

  const maxDimension = 720.0;
  final width = image.naturalWidth.toDouble();
  final height = image.naturalHeight.toDouble();
  if (width <= 0 || height <= 0) {
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
  context.drawImageScaled(
    image,
    0,
    0,
    targetWidth.toDouble(),
    targetHeight.toDouble(),
  );

  return canvas.toDataUrl('image/jpeg', 0.60);
}
