import 'dart:convert';
import 'package:fingloba/models/hisse_model.dart';
import 'package:fingloba/models/parite_model.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'https://api.collectapi.com/economy/';
  static const Map<String, String> _headers = {
    'authorization': 'apikey 0Zoqk7WNDiVg8Fm7ocCsLw:2YQIiBv3dWcwQvHJhIPJZO',
    'content-type': 'application/json',
  };

  static Future<Map<String, dynamic>> _get(String endpoint) async {
    final response =
        await http.get(Uri.parse(_baseUrl + endpoint), headers: _headers);
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('❌ API Hatası: ${response.statusCode}');
    }
  }

  // 📊 Borsadaki Şirketlerin Değerleri (Hisse Senedi)
  Future<List<HisseSenedi>> getHisseSenedi() async {
    final response = await _get('hisseSenedi');
    return (response['result'] as List)
        .map((json) => HisseSenedi.fromJson(json))
        .toList();
  }

  // 🏆 Altın Fiyatları
  Future<List<dynamic>> getGoldPrices() async =>
      (await _get('goldPrice'))['result'];

  // 🪙 Kripto Paralar
  Future<List<dynamic>> getCrypto() async => (await _get('cripto'))['result'];

  // 📈 Canlı Borsa Verileri
  Future<List<dynamic>> getLiveBorsa() async =>
      (await _get('liveBorsa'))['result'];

  // 🌍 Parite Bilgileri
  Future<List<Parite>> getParite() async {
    final response = await _get('parite');
    return (response['result'] as List)
        .map((json) => Parite.fromJson(json))
        .toList();
  }
}
