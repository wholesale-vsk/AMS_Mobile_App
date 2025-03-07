
import '../enums/environment_type.dart';

class AuthEnvironment {
  static const _development = 'https://auth.hexalyte.com/realms/ams-cloud/protocol/openid-connect/token';
  static const _testing = 'https://api.testing.com';
  static const _production = 'https://auth.hexalyte.com/realms/ams-cloud/protocol/openid-connect/token';

  //:::::::::::::::::::::::::::::::::<<privet environment type variable>>::::::::::::::::::::::::::::::::://
  static String get baseURL {
    switch (_currentEnvironment) {
      case EnvironmentType.DEVELOPMENT:
        return _development;
      case EnvironmentType.TESTING:
        return _testing;
      case EnvironmentType.PRODUCTION:
        return _production;
      default:
        return _development;
    }
  }
  //:::::::::::::::::::::::::::::::::<<public environment type variable>>::::::::::::::::::::::::::::::::://
  static const EnvironmentType _currentEnvironment = EnvironmentType.DEVELOPMENT;
}

class DataEnvironment {
  static const _development = 'https://api.ams.hexalyte.com/';
  static const _testing = 'https://api.ams.hexalyte.com/';
  static const _production = 'https://api.ams.hexalyte.com/';

  //:::::::::::::::::::::::::::::::::<<privet environment type variable>>::::::::::::::::::::::::::::::::://
  static String get baseURL {
    switch (_currentEnvironment) {
      case EnvironmentType.DEVELOPMENT:
        return _development;
      case EnvironmentType.TESTING:
        return _testing;
      case EnvironmentType.PRODUCTION:
        return _production;
      default:
        return _development;
    }
  }
  //:::::::::::::::::::::::::::::::::<<public environment type variable>>::::::::::::::::::::::::::::::::://
  static const EnvironmentType _currentEnvironment = EnvironmentType.DEVELOPMENT;
}