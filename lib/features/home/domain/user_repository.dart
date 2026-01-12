import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_provider.dart';
import '../data/user_data_source.dart';

abstract class UserRepository {
  Stream<dynamic> getUserInfo();
  Stream<bool> checkUserDaily();
}

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._dataSource);

  final UserDataSource _dataSource;

  @override
  Stream<dynamic> getUserInfo() {
    return _dataSource.getUserInfo();
  }

  @override
  Stream<bool> checkUserDaily() {
    return _dataSource.checkUserDaily();
  }
}

final userRepositoryProvider = Provider<UserRepository>((ref) {
  ref.watch(authStateChangesProvider);
  return UserRepositoryImpl(ref.read(userDataSourceProvider));
});

final profileDataProvider = StreamProvider<dynamic>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getUserInfo();
});

final dailyCheckProvider = StreamProvider<bool>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return repository.checkUserDaily();
});
