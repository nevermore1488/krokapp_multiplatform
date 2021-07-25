import 'package:flutter/widgets.dart';
import 'package:krokapp_multiplatform/business/usecases/excursion_use_case.dart';
import 'package:krokapp_multiplatform/business/usecases/language_use_case.dart';
import 'package:krokapp_multiplatform/business/usecases/loading_data_use_case.dart';
import 'package:krokapp_multiplatform/business/usecases/map_use_case.dart';
import 'package:krokapp_multiplatform/business/usecases/place_use_case.dart';
import 'package:krokapp_multiplatform/data/api.dart';
import 'package:krokapp_multiplatform/data/dao/cities_dao.dart';
import 'package:krokapp_multiplatform/data/dao/current_language_id_dao.dart';
import 'package:krokapp_multiplatform/data/dao/featured_points_dao.dart';
import 'package:krokapp_multiplatform/data/dao/featured_tags_dao.dart';
import 'package:krokapp_multiplatform/data/dao/languages_dao.dart';
import 'package:krokapp_multiplatform/data/dao/palce_features_dao.dart';
import 'package:krokapp_multiplatform/data/dao/points_dao.dart';
import 'package:krokapp_multiplatform/data/dao/tag_features_dao.dart';
import 'package:krokapp_multiplatform/data/dao/tags_dao.dart';
import 'package:krokapp_multiplatform/data/dao/tags_of_places_dao.dart';
import 'package:krokapp_multiplatform/data/database_provider.dart';
import 'package:krokapp_multiplatform/data/observable_db_executor.dart';
import 'package:krokapp_multiplatform/data/repositories/cities_repository.dart';
import 'package:krokapp_multiplatform/data/repositories/excursion_repository.dart';
import 'package:krokapp_multiplatform/data/repositories/languages_repository.dart';
import 'package:krokapp_multiplatform/data/repositories/points_repository.dart';
import 'package:krokapp_multiplatform/data/repositories/tags_repository.dart';
import 'package:krokapp_multiplatform/presentation/app/krok_app.dart';
import 'package:krokapp_multiplatform/presentation/app/krok_app_view_model.dart';
import 'package:krokapp_multiplatform/presentation/excursion/excursion_settings_view_model.dart';
import 'package:krokapp_multiplatform/ui/snapshot_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppAsyncDependencies {
  ObservableDatabaseExecutor dbExecutor;
  SharedPreferences sharedPreferences;

  AppAsyncDependencies({
    required this.dbExecutor,
    required this.sharedPreferences,
  });
}

class InitApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => FutureBuilder<AppAsyncDependencies>(
        future: obtainAsyncDependencies(),
        builder: (_, snapshot) => SnapshotView<AppAsyncDependencies>(
          snapshot: snapshot,
          onHasData: (value) =>
              _createAppDependencies(snapshot.data!, context, KrokApp()),
          onLoading: KrokApp.createSplashScreen,
        ),
      );

  Future<AppAsyncDependencies> obtainAsyncDependencies() async =>
      AppAsyncDependencies(
        dbExecutor: await DatabaseProvider().obtainDbExecutor(),
        sharedPreferences: await SharedPreferences.getInstance(),
      );

  Widget _createAppDependencies(
    AppAsyncDependencies appAsyncDependencies,
    BuildContext context,
    Widget child,
  ) =>
      MultiProvider(
        providers: [
          Provider<LanguagesRepository>(
            create: (context) => LanguagesRepository(
                LanguagesApiImpl(),
                LanguagesDaoImpl(appAsyncDependencies.dbExecutor),
                CurrentLanguageIdDaoImpl(appAsyncDependencies.dbExecutor)),
          ),
          Provider<CitiesRepository>(
            create: (context) => CitiesRepository(
              CitiesApiImpl(),
              CitiesDaoImpl(appAsyncDependencies.dbExecutor),
            ),
          ),
          Provider<TagsRepository>(
            create: (context) => TagsRepository(
              TagsApiImpl(),
              TagsDaoImpl(appAsyncDependencies.dbExecutor),
              FeaturedTagsDaoImpl(appAsyncDependencies.dbExecutor),
              TagFeaturesDaoImpl(appAsyncDependencies.dbExecutor),
              TagsOfPlacesDaoImpl(appAsyncDependencies.dbExecutor),
            ),
          ),
          Provider<ExcursionRepository>(
            create: (context) => ExcursionRepository(
              appAsyncDependencies.sharedPreferences,
            ),
          ),
          Provider<PointsRepository>(
            create: (context) => PointsRepository(
              PointsApiImpl(),
              PointsDaoImpl(appAsyncDependencies.dbExecutor),
              PlaceFeaturesDaoImpl(appAsyncDependencies.dbExecutor),
              FeaturedPointsDaoImpl(appAsyncDependencies.dbExecutor),
              TagsOfPlacesDaoImpl(appAsyncDependencies.dbExecutor),
            ),
          ),
          ProxyProvider<LanguagesRepository, LanguageUseCase>(
            update: (context, value, previous) => LanguageUseCase(value),
          ),
          ProxyProvider2<CitiesRepository, PointsRepository, PlaceUseCase>(
            update: (context, cities, points, previous) =>
                PlaceUseCase(cities, points),
          ),
          ProxyProvider4<LanguagesRepository, CitiesRepository,
              PointsRepository, TagsRepository, LoadingDataUseCase>(
            update: (context, languages, cities, points, tags, previous) =>
                LoadingDataUseCase(languages, cities, points, tags),
          ),
          ProxyProvider<PointsRepository, MapUseCase>(
            update: (context, value, previous) => MapUseCase(value),
          ),
          ProxyProvider2<TagsRepository, ExcursionRepository, ExcursionUseCase>(
            update: (context, tags, ex, previous) => ExcursionUseCase(tags, ex),
          ),
          ProxyProvider<LoadingDataUseCase, KrokAppViewModel>(
            update: (context, loadingDataUseCase, previous) =>
                KrokAppViewModel(loadingDataUseCase),
          ),
          ProxyProvider<ExcursionUseCase, ExcursionSettingsViewModel>(
            update: (_, value, previous) => ExcursionSettingsViewModel(value),
          ),
        ],
        child: child,
      );
}
