import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DogPhoto extends StatelessWidget {
  const DogPhoto({
    required this.photoPath,
    super.key,
    this.fit = BoxFit.cover,
    this.borderRadius = 24,
    this.cacheWidth,
    this.cacheHeight,
  });

  final String? photoPath;
  final BoxFit fit;
  final double borderRadius;
  final int? cacheWidth;
  final int? cacheHeight;

  @override
  Widget build(BuildContext context) {
    final path = photoPath;
    if (path == null || path.isEmpty || path == 'placeholder' || path.startsWith('favorite:')) {
      return _PlaceholderPhoto(label: path, borderRadius: borderRadius);
    }

    if (path.startsWith('data:image/')) {
      if (kIsWeb) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Image.network(
            path,
            fit: fit,
            cacheWidth: cacheWidth,
            cacheHeight: cacheHeight,
            filterQuality: FilterQuality.none,
            gaplessPlayback: true,
            errorBuilder: (context, error, stackTrace) =>
                _PlaceholderPhoto(label: path, borderRadius: borderRadius),
          ),
        );
      }

      final commaIndex = path.indexOf(',');
      if (commaIndex > 0) {
        final bytes = base64Decode(path.substring(commaIndex + 1));
        return ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Image.memory(
            bytes,
            fit: fit,
            cacheWidth: cacheWidth,
            cacheHeight: cacheHeight,
            filterQuality: FilterQuality.none,
            gaplessPlayback: true,
          ),
        );
      }
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.network(
        path,
        fit: fit,
        cacheWidth: cacheWidth,
        cacheHeight: cacheHeight,
        filterQuality: FilterQuality.none,
        gaplessPlayback: true,
        errorBuilder: (context, error, stackTrace) =>
            _PlaceholderPhoto(label: path, borderRadius: borderRadius),
      ),
    );
  }
}

class _PlaceholderPhoto extends StatelessWidget {
  const _PlaceholderPhoto({
    required this.borderRadius,
    this.label,
  });

  final String? label;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    String? text;
    final raw = label;
    if (raw != null && raw.startsWith('favorite:') && raw.length > 9) {
      text = raw.substring(9, 10).toUpperCase();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE7D5BE), Color(0xFFBCDCCC), Color(0xFFF7E7C0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: text == null
              ? const Icon(Icons.pets_rounded, size: 72, color: Colors.white70)
              : Text(
                  text,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
        ),
      ),
    );
  }
}
