import 'dart:async';
import 'dart:html' as html;

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

  input.onChange.first.then((_) {
    final file = input.files?.isNotEmpty == true ? input.files!.first : null;
    if (file == null) {
      if (!completer.isCompleted) {
        completer.complete(null);
      }
      return;
    }

    final reader = html.FileReader();
    reader.onLoad.first.then((_) {
      if (!completer.isCompleted) {
        completer.complete(reader.result as String?);
      }
    });
    reader.onError.first.then((_) {
      if (!completer.isCompleted) {
        completer.complete(null);
      }
    });
    reader.readAsDataUrl(file);
  });

  input.click();
  return completer.future;
}
