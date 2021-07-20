import 'package:krokapp_multiplatform/data/api.dart';
import 'package:krokapp_multiplatform/data/dao/cities_dao.dart';
import 'package:krokapp_multiplatform/data/pojo/place.dart';
import 'package:krokapp_multiplatform/data/select_args.dart';
import 'package:krokapp_multiplatform/data/tables/cities_table.dart';

class CitiesRepository {
  CitiesApi _citiesApi;
  CitiesDao _citiesDao;

  CitiesRepository(
    this._citiesApi,
    this._citiesDao,
  );

  Stream<List<Place>> getCitiesBySelectArgs(
    SelectArgs selectArgs,
  ) =>
      _citiesDao.getCitiesBySelectArgs(selectArgs).asPlaces();

  Future<void> loadCities() async {
    var cities = await _citiesDao.getAll().first;
    if (cities.isEmpty) {
      cities = await _citiesApi.getCities(111111).first;
      _citiesDao.add(cities);
    }
  }
}
