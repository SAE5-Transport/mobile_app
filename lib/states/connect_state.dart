import 'package:async/async.dart';
import 'package:bdaya_shared_value/bdaya_shared_value.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:logging/logging.dart';
import 'package:oidc/oidc.dart';
import 'package:oidc_default_store/oidc_default_store.dart';

final exampleLogger = Logger('oidc.example');

OidcUserManager currentManager = duendeManager;

final duendeManager = OidcUserManager.lazy(
  discoveryDocumentUri: OidcUtils.getOpenIdConfigWellKnownUri(
    Uri.parse(
        'http://auth.hexatransit.clarifygdps.com/.well-known/openid-configuration'),
  ),

  // this is a public client,
  // so we use [OidcClientAuthentication.none] constructor.
  clientCredentials: const OidcClientAuthentication.clientSecretBasic(
      clientId: "faknioafioanfioanfoanfoienriofcanjabfoinafjbfaf",
      clientSecret: "fokafpaofjkopajfoiajfoiancoianiocnaoincioa"),
  store: OidcDefaultStore(),

  // keyStore: JsonWebKeyStore(),
  settings: OidcUserManagerSettings(
    uiLocales: ['fr', 'en'],
    refreshBefore: (token) {
      return const Duration(seconds: 1);
    },
    strictJwtVerification: false,
    // set to true to enable offline auth
    supportOfflineAuth: false,
    // scopes supported by the provider and needed by the client.
    scope: ['openid', 'profile', 'email', 'address', 'phone'],
    redirectUri: Uri.parse('com.uwucorp.hexatransit://redirect'),
  ),
);

final initMemoizer = AsyncMemoizer<void>();

Future<void> initApp() async {
  await initMemoizer.runOnce(() async {
    currentManager.userChanges().listen((event) {
      cachedAuthedUser.$ = event;
      exampleLogger.info(
        'User changed: ${event?.claims.toJson()}, info: ${event?.userInfo}',
      );
    });

    await currentManager.init();
  });
}

bool isConnected(BuildContext? context) {
  if(cachedAuthedUser.of(context) == null) {
    return false;
  }
  return true;
}

final cachedAuthedUser = SharedValue<OidcUser?>(value: null);
