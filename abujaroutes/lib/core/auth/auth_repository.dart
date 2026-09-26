import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// A local-only account record. Only a salted hash of the password is
/// ever stored — never the plaintext password.
class AuthAccount {
  final String name;
  final String contact; // email or phone
  final String passwordHash;
  final String salt;

  const AuthAccount({
    required this.name,
    required this.contact,
    required this.passwordHash,
    required this.salt,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'contact': contact,
        'passwordHash': passwordHash,
        'salt': salt,
      };

  factory AuthAccount.fromMap(Map map) => AuthAccount(
        name: map['name'] as String,
        contact: map['contact'] as String,
        passwordHash: map['passwordHash'] as String,
        salt: map['salt'] as String,
      );
}

/// Thrown when a signup or login request can't be fulfilled.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
  @override
  String toString() => message;
}

/// Local-only authentication: no backend, no network calls. Accounts are
/// persisted in a Hive box keyed by a normalized contact (email/phone),
/// with a salted SHA-256 password hash. A separate session box tracks
/// which account (if any) is currently signed in on this device.
class AuthRepository {
  AuthRepository._();
  static final AuthRepository instance = AuthRepository._();

  static const String _accountsBoxName = 'auth_accounts_box';
  static const String _sessionBoxName = 'auth_session_box';
  static const String _sessionKey = 'loggedInContact';

  Box? _accounts;
  Box? _session;

  /// Opens the local boxes. Safe to call multiple times.
  Future<void> init() async {
    if (_accounts != null && _session != null) return;
    _accounts = Hive.isBoxOpen(_accountsBoxName) ? Hive.box(_accountsBoxName) : await Hive.openBox(_accountsBoxName);
    _session = Hive.isBoxOpen(_sessionBoxName) ? Hive.box(_sessionBoxName) : await Hive.openBox(_sessionBoxName);
  }

  String _normalize(String contact) => contact.trim().toLowerCase();

  String _generateSalt([int length = 16]) {
    final random = Random.secure();
    final bytes = List<int>.generate(length, (_) => random.nextInt(256));
    return base64UrlEncode(bytes);
  }

  /// Salted SHA-256 hash: sha256(salt + password).
  String hashPassword(String password, String salt) {
    final bytes = utf8.encode('$salt:$password');
    return sha256.convert(bytes).toString();
  }

  bool get isLoggedIn => (_session?.get(_sessionKey) as String?)?.isNotEmpty ?? false;

  /// The contact (email/phone) of the currently logged-in account, if any.
  String? get currentContact => _session?.get(_sessionKey) as String?;

  AuthAccount? get currentAccount {
    final contact = currentContact;
    if (contact == null) return null;
    return getAccount(contact);
  }

  AuthAccount? getAccount(String contact) {
    final raw = _accounts?.get(_normalize(contact));
    if (raw == null) return null;
    return AuthAccount.fromMap(Map<String, dynamic>.from(raw as Map));
  }

  /// Creates a new local account. Throws [AuthException] if a name,
  /// contact or password is missing/invalid, or an account with this
  /// contact already exists.
  Future<AuthAccount> signUp({
    required String name,
    required String contact,
    required String password,
  }) async {
    await init();
    final trimmedName = name.trim();
    final normalizedContact = _normalize(contact);

    if (trimmedName.isEmpty) {
      throw const AuthException('Please enter your name.');
    }
    if (normalizedContact.isEmpty) {
      throw const AuthException('Please enter an email or phone number.');
    }
    if (password.length < 6) {
      throw const AuthException('Password must be at least 6 characters.');
    }
    if (_accounts!.containsKey(normalizedContact)) {
      throw const AuthException('An account with this email/phone already exists.');
    }

    final salt = _generateSalt();
    final account = AuthAccount(
      name: trimmedName,
      contact: normalizedContact,
      passwordHash: hashPassword(password, salt),
      salt: salt,
    );

    await _accounts!.put(normalizedContact, account.toMap());
    await _session!.put(_sessionKey, normalizedContact);
    return account;
  }

  /// Verifies credentials and starts a session. Throws [AuthException]
  /// if the account doesn't exist or the password is wrong.
  Future<AuthAccount> logIn({required String contact, required String password}) async {
    await init();
    final normalizedContact = _normalize(contact);
    final account = getAccount(normalizedContact);
    if (account == null) {
      throw const AuthException('No account found for this email/phone.');
    }
    final attemptedHash = hashPassword(password, account.salt);
    if (attemptedHash != account.passwordHash) {
      throw const AuthException('Incorrect password.');
    }
    await _session!.put(_sessionKey, normalizedContact);
    return account;
  }

  /// Clears the persisted session. Accounts themselves are left intact.
  Future<void> logOut() async {
    await init();
    await _session!.delete(_sessionKey);
  }
}
