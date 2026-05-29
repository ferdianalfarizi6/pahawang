import 'package:flutter/material.dart';
import '../utils/error_handler.dart';
import '../core/dio_client.dart';
import '../models/package_model.dart';

class PackagesProvider with ChangeNotifier {
  final _dio = DioClient().dio;

  List<TourPackage> _packages = [];
  bool _isLoading = false;
  String? _error;
  int _totalPackages = 0;
  int _page = 1;
  int _totalPages = 1;

  List<TourPackage> get packages => _packages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalPackages => _totalPackages;

  Future<void> fetchPackages({String? search, bool isRefresh = true}) async {
    if (isRefresh) {
      _packages = [];
      _page = 1;
    } else {
      if (_page >= _totalPages) return;
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

      final response = await _dio.get('/packages', queryParameters: queryParams);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        final meta = response.data['meta'];

        final List<TourPackage> fetched = data.map((x) => TourPackage.fromJson(x)).toList();
        
        if (isRefresh) {
          _packages = fetched;
        } else {
          _packages.addAll(fetched);
        }

        _totalPackages = meta['total'] ?? 0;
        _totalPages = meta['totalPages'] ?? 1;
      } else {
        throw Exception('Gagal memuat paket wisata dari server.');
      }
    } catch (e) {
      _error = ErrorHandler.getErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<TourPackage?> fetchPackageDetail(String id) async {
    try {
      final response = await _dio.get('/packages/$id');
      if (response.statusCode == 200) {
        return TourPackage.fromJson(response.data);
      }
    } catch (e) {
      debugPrint('Error loading package detail: $e');
    }
    return null;
  }
}
