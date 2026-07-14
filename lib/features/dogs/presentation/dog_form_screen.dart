import 'package:dog_friend_manager/core/utils/date_utils.dart';
import 'package:dog_friend_manager/data/models/dog_profile.dart';
import 'package:dog_friend_manager/features/dogs/viewmodels/dogs_controller.dart';
import 'package:dog_friend_manager/shared/services/image_picker_service.dart';
import 'package:dog_friend_manager/shared/widgets/dog_photo.dart';
import 'package:dog_friend_manager/shared/widgets/glass_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DogFormScreen extends ConsumerStatefulWidget {
  const DogFormScreen({
    super.key,
    this.initialDog,
  });

  final DogProfile? initialDog;

  @override
  ConsumerState<DogFormScreen> createState() => _DogFormScreenState();
}

class _DogFormScreenState extends ConsumerState<DogFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _weightController = TextEditingController();
  final _coatColorController = TextEditingController();
  final _ownerController = TextEditingController();
  final _instagramController = TextEditingController();
  final _lineController = TextEditingController();
  final _phoneController = TextEditingController();
  final _metPlaceController = TextEditingController();
  final _eventController = TextEditingController();
  final _addressController = TextEditingController();
  final _currentAreaController = TextEditingController();
  final _regionController = TextEditingController();
  final _personalityController = TextEditingController();
  final _favoriteSnackController = TextEditingController();
  final _favoriteToyController = TextEditingController();
  final _favoritePlayController = TextEditingController();
  final _dislikesController = TextEditingController();
  final _tagsController = TextEditingController();
  final _noteController = TextEditingController();

  DogGender _gender = DogGender.unknown;
  int _friendliness = 3;
  bool _isMyDog = false;
  bool _isFavorite = false;
  DateTime? _birthday;
  late DateTime _metDate;
  late List<String> _photoPaths;
  String? _favoritePhotoPath;

  bool get _isEditing => widget.initialDog != null;

  @override
  void initState() {
    super.initState();
    final dog = widget.initialDog;
    _nameController.text = dog?.name ?? '';
    _breedController.text = dog?.breed ?? '';
    _weightController.text = dog?.weightKg?.toString() ?? '';
    _coatColorController.text = dog?.coatColor ?? '';
    _ownerController.text = dog?.ownerName ?? '';
    _instagramController.text = dog?.instagram ?? '';
    _lineController.text = dog?.lineId ?? '';
    _phoneController.text = dog?.phoneNumber ?? '';
    _metPlaceController.text = dog?.metPlace ?? '';
    _eventController.text = dog?.eventName ?? '';
    _addressController.text = dog?.address ?? '';
    _currentAreaController.text = dog?.currentArea ?? '';
    _regionController.text = dog?.region ?? '';
    _personalityController.text = dog?.personality ?? '';
    _favoriteSnackController.text = dog?.favoriteSnack ?? '';
    _favoriteToyController.text = dog?.favoriteToy ?? '';
    _favoritePlayController.text = dog?.favoritePlay ?? '';
    _dislikesController.text = dog?.dislikes ?? '';
    _tagsController.text = dog?.tags.join(', ') ?? '';
    _noteController.text = dog?.note ?? '';
    _gender = dog?.gender ?? DogGender.unknown;
    _friendliness = dog?.friendliness ?? 3;
    _isMyDog = dog?.isMyDog ?? false;
    _isFavorite = dog?.isFavorite ?? false;
    _birthday = dog?.birthday;
    _metDate = dog?.metDate ?? DateTime.now();
    _photoPaths = List<String>.from(
      dog?.photoPaths ?? const <String>['placeholder'],
    );
    _favoritePhotoPath = dog?.favoritePhotoPath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _weightController.dispose();
    _coatColorController.dispose();
    _ownerController.dispose();
    _instagramController.dispose();
    _lineController.dispose();
    _phoneController.dispose();
    _metPlaceController.dispose();
    _eventController.dispose();
    _addressController.dispose();
    _currentAreaController.dispose();
    _regionController.dispose();
    _personalityController.dispose();
    _favoriteSnackController.dispose();
    _favoriteToyController.dispose();
    _favoritePlayController.dispose();
    _dislikesController.dispose();
    _tagsController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'ワンコカードを編集' : 'ワンコを登録'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Text(
              _isEditing
                  ? '登録済みの内容をそのまま修正できます。'
                  : '出会ったワンコの情報をかわいく残しましょう。',
            ),
            const SizedBox(height: 16),
            _PhotoEditorSection(
              photoPaths: _photoPaths,
              favoritePhotoPath: _favoritePhotoPath,
              onAddPhoto: _addPhoto,
              onReplacePhoto: _replacePhoto,
              onDeletePhoto: _deletePhoto,
              onFavoritePhoto: _setFavoritePhoto,
            ),
            const SizedBox(height: 16),
            GlassCard(
              child: Column(
                children: [
                  SwitchListTile(
                    value: _isMyDog,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('マイワンコにする'),
                    subtitle: const Text('自分のワンコとしてホーム上位に表示します。'),
                    onChanged: (value) => setState(() => _isMyDog = value),
                  ),
                  SwitchListTile(
                    value: _isFavorite,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('お気に入り登録'),
                    subtitle: const Text('一覧で見つけやすくなります。'),
                    onChanged: (value) => setState(() => _isFavorite = value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _sectionTitle(context, '基本情報'),
            _buildTextField(_nameController, '犬の名前', required: true),
            _buildTextField(_breedController, '犬種', required: true),
            const SizedBox(height: 12),
            DropdownButtonFormField<DogGender>(
              initialValue: _gender,
              decoration: const InputDecoration(labelText: '性別'),
              items: DogGender.values
                  .map(
                    (gender) => DropdownMenuItem(
                      value: gender,
                      child: Text(gender.label),
                    ),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => _gender = value ?? DogGender.unknown),
            ),
            const SizedBox(height: 12),
            _DateField(
              label: '誕生日',
              value: _birthday,
              onTap: () async {
                final picked = await _pickDate(
                  initialDate: _birthday ?? DateTime(2022, 1, 1),
                );
                if (picked != null) {
                  setState(() => _birthday = picked);
                }
              },
              onClear: _birthday == null
                  ? null
                  : () => setState(() => _birthday = null),
            ),
            _buildTextField(
              _weightController,
              '体重(kg)',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            _buildTextField(_coatColorController, '毛色'),
            const SizedBox(height: 16),
            _sectionTitle(context, '飼い主さん'),
            _buildTextField(_ownerController, '飼い主さんの名前'),
            _buildTextField(_instagramController, 'Instagram'),
            _buildTextField(_lineController, 'LINE'),
            _buildTextField(
              _phoneController,
              '電話番号',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            _sectionTitle(context, '出会った情報'),
            _DateField(
              label: '出会った日',
              value: _metDate,
              onTap: () async {
                final picked = await _pickDate(initialDate: _metDate);
                if (picked != null) {
                  setState(() => _metDate = picked);
                }
              },
            ),
            _buildTextField(_metPlaceController, '出会った場所'),
            _buildTextField(_eventController, 'イベント名'),
            _buildTextField(_addressController, '住所'),
            _buildTextField(_currentAreaController, '現在住んでいる地域'),
            _buildTextField(_regionController, '地域'),
            const SizedBox(height: 18),
            Text('仲良し度: $_friendliness'),
            Slider(
              value: _friendliness.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              label: '$_friendliness',
              onChanged: (value) =>
                  setState(() => _friendliness = value.round()),
            ),
            const SizedBox(height: 16),
            _sectionTitle(context, '性格とメモ'),
            _buildTextField(_personalityController, '性格'),
            _buildTextField(_favoriteSnackController, '好きなおやつ'),
            _buildTextField(_favoriteToyController, '好きなおもちゃ'),
            _buildTextField(_favoritePlayController, '好きな遊び'),
            _buildTextField(_dislikesController, '苦手なこと'),
            _buildTextField(
              _tagsController,
              'タグ',
              helperText: 'カンマ区切りで入力',
            ),
            _buildTextField(_noteController, '備考', maxLines: 5),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_rounded),
              label: Text(_isEditing ? '更新する' : '登録する'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool required = false,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? helperText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label, helperText: helperText),
        validator: required
            ? (value) => value == null || value.trim().isEmpty
                ? '$labelを入力してください'
                : null
            : null,
      ),
    );
  }

  Future<DateTime?> _pickDate({required DateTime initialDate}) {
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
  }

  Future<void> _addPhoto() async {
    final image = await _pickPhotoWithDialog();
    if (image == null) {
      return;
    }

    setState(() {
      _photoPaths.removeWhere((path) => path == 'placeholder');
      _photoPaths.add(image);
      _favoritePhotoPath ??= image;
    });
  }

  Future<void> _replacePhoto(int index) async {
    final image = await _pickPhotoWithDialog();
    if (image == null) {
      return;
    }

    final oldPath = _photoPaths[index];
    setState(() {
      _photoPaths[index] = image;
      if (_favoritePhotoPath == oldPath || _favoritePhotoPath == null) {
        _favoritePhotoPath = image;
      }
    });
  }

  void _deletePhoto(int index) {
    final removed = _photoPaths[index];
    setState(() {
      _photoPaths.removeAt(index);
      if (_photoPaths.isEmpty) {
        _photoPaths = ['placeholder'];
      }
      if (_favoritePhotoPath == removed) {
        final firstRealPhoto = _photoPaths.firstWhere(
          (path) => path != 'placeholder',
          orElse: () => 'placeholder',
        );
        _favoritePhotoPath =
            firstRealPhoto == 'placeholder' ? null : firstRealPhoto;
      }
    });
  }

  void _setFavoritePhoto(String photoPath) {
    setState(() {
      _favoritePhotoPath = photoPath == 'placeholder' ? null : photoPath;
    });
  }

  Future<String?> _pickPhotoWithDialog() async {
    final source = await showDialog<_PhotoSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('写真を追加'),
        content: const Text(
          'カメラで撮影するか、保存済みの写真を選ぶか選択してください。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(_PhotoSource.gallery),
            child: const Text('写真を選ぶ'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(_PhotoSource.camera),
            child: const Text('カメラで撮る'),
          ),
        ],
      ),
    );

    if (source == null) {
      return null;
    }

    return pickDogPhoto(captureFromCamera: source == _PhotoSource.camera);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final controller = ref.read(dogsControllerProvider.notifier);
    final initialDog = widget.initialDog;
    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList(growable: false);
    final weight = double.tryParse(_weightController.text.trim());
    final normalizedPhotos = _photoPaths
        .where((path) => path.isNotEmpty)
        .toList(growable: false);
    final photos = normalizedPhotos.isEmpty
        ? const ['placeholder']
        : normalizedPhotos;
    final history = _buildEncounterHistory(initialDog);

    final dog = DogProfile(
      id: initialDog?.id ?? controller.createDogId(),
      name: _nameController.text.trim(),
      breed: _breedController.text.trim(),
      gender: _gender,
      birthday: _birthday,
      weightKg: weight,
      coatColor: _coatColorController.text.trim(),
      photoPaths: photos,
      ownerName: _ownerController.text.trim(),
      instagram: _instagramController.text.trim(),
      lineId: _lineController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      metDate: _metDate,
      metPlace: _metPlaceController.text.trim(),
      eventName: _eventController.text.trim(),
      address: _addressController.text.trim(),
      currentArea: _currentAreaController.text.trim(),
      region: _regionController.text.trim(),
      friendliness: _friendliness,
      personality: _personalityController.text.trim(),
      favoriteSnack: _favoriteSnackController.text.trim(),
      favoriteToy: _favoriteToyController.text.trim(),
      favoritePlay: _favoritePlayController.text.trim(),
      dislikes: _dislikesController.text.trim(),
      note: _noteController.text.trim(),
      tags: tags,
      isFavorite: _isFavorite,
      isMyDog: _isMyDog,
      favoritePhotoPath: _favoritePhotoPath,
      latitude: initialDog?.latitude,
      longitude: initialDog?.longitude,
      encounterHistory: history,
    );

    await controller.saveDog(dog);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  List<EncounterLog> _buildEncounterHistory(DogProfile? initialDog) {
    final primaryEntry = EncounterLog(
      date: _metDate,
      eventName: _eventController.text.trim(),
      placeName: _metPlaceController.text.trim(),
      address: _addressController.text.trim(),
      memo: _noteController.text.trim(),
    );

    final existing = List<EncounterLog>.from(
      initialDog?.encounterHistory ?? const <EncounterLog>[],
    );
    if (existing.isEmpty) {
      return [primaryEntry];
    }

    existing[0] = primaryEntry;
    return existing;
  }
}

class _PhotoEditorSection extends StatelessWidget {
  const _PhotoEditorSection({
    required this.photoPaths,
    required this.favoritePhotoPath,
    required this.onAddPhoto,
    required this.onReplacePhoto,
    required this.onDeletePhoto,
    required this.onFavoritePhoto,
  });

  final List<String> photoPaths;
  final String? favoritePhotoPath;
  final VoidCallback onAddPhoto;
  final ValueChanged<int> onReplacePhoto;
  final ValueChanged<int> onDeletePhoto;
  final ValueChanged<String> onFavoritePhoto;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('写真', style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              FilledButton.icon(
                onPressed: onAddPhoto,
                icon: const Icon(Icons.add_a_photo_rounded),
                label: const Text('追加'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'お気に入り写真は一覧カードに表示されます。写真ごとに差し替えもできます。',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 126,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: photoPaths.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final photoPath = photoPaths[index];
                final isFavorite = favoritePhotoPath == photoPath ||
                    (favoritePhotoPath == null &&
                        index == 0 &&
                        photoPath != 'placeholder');

                return SizedBox(
                  width: 140,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: DogPhoto(photoPath: photoPath, borderRadius: 24),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _MiniPhotoButton(
                              icon: isFavorite
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              onTap: () => onFavoritePhoto(photoPath),
                            ),
                            const SizedBox(width: 6),
                            _MiniPhotoButton(
                              icon: Icons.edit_rounded,
                              onTap: () => onReplacePhoto(index),
                            ),
                            const SizedBox(width: 6),
                            _MiniPhotoButton(
                              icon: Icons.delete_outline_rounded,
                              onTap: photoPaths.length == 1
                                  ? null
                                  : () => onDeletePhoto(index),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniPhotoButton extends StatelessWidget {
  const _MiniPhotoButton({
    required this.icon,
    this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.88),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: Icon(icon, size: 18),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
    this.onClear,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onClear != null)
                  IconButton(
                    onPressed: onClear,
                    icon: const Icon(Icons.clear_rounded),
                  ),
                const Icon(Icons.calendar_month_rounded),
                const SizedBox(width: 12),
              ],
            ),
          ),
          child: Text(value == null ? '未設定' : AppDateUtils.formatDate(value!)),
        ),
      ),
    );
  }
}

enum _PhotoSource { camera, gallery }
