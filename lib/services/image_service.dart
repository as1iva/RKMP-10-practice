import 'dart:convert';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:movie_catalog/services/logger_service.dart';

class ImageService {
  static final ImageService _instance = ImageService._internal();
  factory ImageService() => _instance;
  ImageService._internal();

  final DefaultCacheManager _cacheManager = DefaultCacheManager();

  static const int _imagePoolSize = 20;
  static const int _avatarPoolSize = 10;
  static const String _keyUsedImages = 'used_images';
  static const String _keyAvailableImages = 'available_images';
  static const String _keyUsedAvatars = 'used_avatars';
  static const String _keyAvailableAvatars = 'available_avatars';

  List<String> _availableImages = [];
  Set<String> _usedImages = {};
  List<String> _availableAvatars = [];
  Set<String> _usedAvatars = {};
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();

    final usedImagesJson = prefs.getString(_keyUsedImages);
    final availableImagesJson = prefs.getString(_keyAvailableImages);

    if (usedImagesJson != null) _usedImages = Set<String>.from(jsonDecode(usedImagesJson));
    if (availableImagesJson != null) _availableImages = List<String>.from(jsonDecode(availableImagesJson));

    final usedAvatarsJson = prefs.getString(_keyUsedAvatars);
    final availableAvatarsJson = prefs.getString(_keyAvailableAvatars);

    if (usedAvatarsJson != null) _usedAvatars = Set<String>.from(jsonDecode(usedAvatarsJson));
    if (availableAvatarsJson != null) _availableAvatars = List<String>.from(jsonDecode(availableAvatarsJson));

    if (_availableImages.isEmpty) await _generateImagePool();
    if (_availableAvatars.isEmpty) await _generateAvatarPool();

    _isInitialized = true;
  }

  Future<void> _generateImagePool() async {
    _availableImages = List.generate(
      _imagePoolSize,
      (i) => 'https://picsum.photos/seed/movie${DateTime.now().millisecondsSinceEpoch + i}/400/600',
    );
    await _saveState();
  }

  Future<void> _generateAvatarPool() async {
    _availableAvatars = List.generate(
      _avatarPoolSize,
      (i) => 'https://picsum.photos/seed/avatar${DateTime.now().millisecondsSinceEpoch + i + 10000}/400/400',
    );
    await _saveState();
  }

  Future<void> preloadImagePool() async {
    await initialize();

    for (final url in _availableImages) {
      try {
        await _cacheManager.downloadFile(url);
        LoggerService.debug('Предзагрузка картинки: $url');
        await Future.delayed(const Duration(milliseconds: 100));
      } catch (e) {
        LoggerService.warning('Не удалось предзагрузить картинку $url: $e');
      }
    }

    for (final url in _availableAvatars) {
      try {
        await _cacheManager.downloadFile(url);
        LoggerService.debug('Предзагрузка аватара: $url');
        await Future.delayed(const Duration(milliseconds: 100));
      } catch (e) {
        LoggerService.warning('Не удалось предзагрузить аватар $url: $e');
      }
    }
  }

  Future<String?> getNextMovieImage() async {
    await initialize();

    if (_availableImages.isEmpty) {
      await _generateImagePool();
      _preloadImages(_availableImages).catchError(
        (e) => LoggerService.warning('Не удалось предзагрузить картинки: $e'),
      );
    }

    if (_availableImages.isEmpty) return null;

    final imageUrl = _availableImages.removeAt(0);
    _usedImages.add(imageUrl);
    await _saveState();
    return imageUrl;
  }

  Future<String?> getNextAvatar() async {
    await initialize();

    if (_availableAvatars.isEmpty) {
      await _generateAvatarPool();
      _preloadImages(_availableAvatars).catchError(
        (e) => LoggerService.warning('Не удалось предзагрузить аватары: $e'),
      );
    }

    if (_availableAvatars.isEmpty) return null;

    final avatarUrl = _availableAvatars.removeAt(0);
    _usedAvatars.add(avatarUrl);
    await _saveState();
    return avatarUrl;
  }

  Future<void> _preloadImages(List<String> urls) async {
    for (final url in urls) {
      try {
        await _cacheManager.downloadFile(url);
        await Future.delayed(const Duration(milliseconds: 100));
      } catch (e) {
        LoggerService.warning('Ошибка при предзагрузке $url: $e');
      }
    }
  }

  Future<void> releaseImage(String imageUrl) async {
    await initialize();
    if (_usedImages.remove(imageUrl)) {
      _availableImages.add(imageUrl);
      await _saveState();
    }
  }

  Future<void> releaseAvatar(String avatarUrl) async {
    await initialize();
    if (_usedAvatars.remove(avatarUrl)) {
      _availableAvatars.add(avatarUrl);
      await _saveState();
    }
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUsedImages, jsonEncode(_usedImages.toList()));
    await prefs.setString(_keyAvailableImages, jsonEncode(_availableImages));
    await prefs.setString(_keyUsedAvatars, jsonEncode(_usedAvatars.toList()));
    await prefs.setString(_keyAvailableAvatars, jsonEncode(_availableAvatars));
  }

  String getRandomMovieImageUrl(String movieId) {
    final seed = movieId.hashCode.abs();
    return 'https://picsum.photos/seed/$seed/400/600';
  }

  String getRandomProfileImageUrl(String userId) {
    final seed = userId.hashCode.abs();
    return 'https://picsum.photos/seed/user$seed/400/400';
  }

  Future<void> removeFromCache(String url) async {
    try {
      await _cacheManager.removeFile(url);
    } catch (e) {
      LoggerService.error('Не удалось удалить из кэша', e);
    }
  }

  Future<void> preloadImage(String url) async {
    try {
      await _cacheManager.downloadFile(url);
    } catch (e) {
      LoggerService.error('Не удалось предзагрузить картинку', e);
    }
  }

  Future<void> clearCache() async {
    try {
      await _cacheManager.emptyCache();
    } catch (e) {
      LoggerService.error('Не удалось очистить кэш', e);
    }
  }

  Future<int> getAvailableImagesCount() async {
    await initialize();
    return _availableImages.length;
  }

  Future<int> getAvailableAvatarsCount() async {
    await initialize();
    return _availableAvatars.length;
  }
}
