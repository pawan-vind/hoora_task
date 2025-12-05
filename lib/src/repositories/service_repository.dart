import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

import '../models/service.dart';

class ServiceRepository {
  final Dio dio;
  final String? baseUrl;

  ServiceRepository({Dio? dio, this.baseUrl}) : dio = dio ?? Dio();

  Future<List<Service>> fetchServices({int page = 1, int pageSize = 20}) async {
    if (baseUrl != null) {
      try {
        final resp = await dio.get(
          '$baseUrl/services',
          queryParameters: {'page': page, 'pageSize': pageSize},
        );
        final decoded = resp.data;
        final wrapper = ServicesResponse.fromJson(decoded);
        return wrapper.services;
      } catch (_) {
        rethrow;
      }
    }

    final jsonStr = await rootBundle.loadString('assets/services.json');
    final decoded = json.decode(jsonStr);
    final resp = ServicesResponse.fromJson(decoded);
    final all = resp.services;
    final start = (page - 1) * pageSize;
    if (start >= all.length) return <Service>[];
    final end = (start + pageSize) < all.length
        ? (start + pageSize)
        : all.length;
    return all.sublist(start, end);
  }
}
