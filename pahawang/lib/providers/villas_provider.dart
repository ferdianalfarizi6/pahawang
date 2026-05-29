import 'package:flutter/material.dart';
import '../utils/error_handler.dart';
import '../core/dio_client.dart';
import '../models/villa_model.dart';

class VillasProvider with ChangeNotifier {
  final _dio = DioClient().dio;

  List<Villa> _villas = [];
  bool _isLoading = false;
  String? _error;
  int _totalVillas = 0;
  int _page = 1;
  int _totalPages = 1;

  List<Villa> get villas => _villas;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalVillas => _totalVillas;

  Future<void> fetchVillas({String? search, int page = 1, bool isRefresh = true}) async {
    if (isRefresh) {
      _villas = [];
      _page = 1;
    } else {
      if (_page >= _totalPages) return; // No further pages to load
      _page++;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final queryParams = {
        'page': _page,
        'limit': 10,
        if (search != null && search.isNotEmpty) 'search': search,
      };

      final response = await _dio.get('/villas', queryParameters: queryParams);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        final meta = response.data['meta'];

        final List<Villa> fetched = data.map((x) => Villa.fromJson(x)).toList();
        
        if (isRefresh) {
          _villas = fetched;
        } else {
          _villas.addAll(fetched);
        }

        _totalVillas = meta['total'] ?? 0;
        _totalPages = meta['totalPages'] ?? 1;
      } else {
        throw Exception('Gagal memuat daftar villa dari server.');
      }
    } catch (e) {
      _error = ErrorHandler.getErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Villa?> fetchVillaDetail(String id) async {
    try {
      final response = await _dio.get('/villas/$id');
      if (response.statusCode == 200) {
        return Villa.fromJson(response.data);
      }
    } catch (e) {
      debugPrint('Error loading villa detail: $e');
    }
    return null;
  }

  Future<bool> createVilla(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _dio.post('/villas', data: data);
      if (response.statusCode == 201) {
        await fetchVillas(isRefresh: true);
        return true;
      }
      return false;
    } catch (e) {
      _error = ErrorHandler.getErrorMessage(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateVilla(String id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _dio.patch('/villas/$id', data: data);
      if (response.statusCode == 200) {
        await fetchVillas(isRefresh: true);
        return true;
      }
      return false;
    } catch (e) {
      _error = ErrorHandler.getErrorMessage(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteVilla(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _dio.delete('/villas/$id');
      if (response.statusCode == 200) {
        await fetchVillas(isRefresh: true);
        return true;
      }
      return false;
    } catch (e) {
      _error = ErrorHandler.getErrorMessage(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

