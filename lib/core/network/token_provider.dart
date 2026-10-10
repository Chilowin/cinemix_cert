import 'package:firebase_auth/firebase_auth.dart';

abstract class TokenProvider {
  Future<String?> getToken({bool forceRefresh = false});
}

class FirebaseTokenProvider implements TokenProvider {
  FirebaseTokenProvider(this._auth);

  final FirebaseAuth _auth;

  @override
  Future<String?> getToken({bool forceRefresh = false}) async {
    return _auth.currentUser?.getIdToken(forceRefresh);
  }
}
