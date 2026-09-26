import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:abujaroutes/core/auth/auth_repository.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('abujaroutes_auth_test_hive');
    Hive.init(tempDir.path);
  });

  tearDownAll(() async {
    // Best-effort cleanup: under heavy parallel test load, closing Hive
    // can occasionally stall. Bound it so a slow teardown never hangs
    // the whole suite — the OS reclaims the temp dir either way.
    try {
      await Hive.close().timeout(const Duration(seconds: 5));
    } catch (_) {
      // Ignore — cleanup is best-effort.
    }
    try {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    } catch (_) {
      // Ignore — cleanup is best-effort.
    }
  });

  setUp(() async {
    await AuthRepository.instance.init();
    for (final boxName in ['auth_accounts_box', 'auth_session_box']) {
      if (Hive.isBoxOpen(boxName)) {
        await Hive.box(boxName).clear();
      }
    }
  });

  test('signup succeeds and starts a session', () async {
    final account = await AuthRepository.instance.signUp(
      name: 'Ada Rider',
      contact: 'ada@example.com',
      password: 'secret1',
    );

    expect(account.name, 'Ada Rider');
    expect(account.contact, 'ada@example.com');
    expect(AuthRepository.instance.isLoggedIn, isTrue);
    expect(AuthRepository.instance.currentContact, 'ada@example.com');
  });

  test('signup rejects a duplicate account', () async {
    await AuthRepository.instance.signUp(
      name: 'Ada Rider',
      contact: 'ada@example.com',
      password: 'secret1',
    );

    expect(
      () => AuthRepository.instance.signUp(
        name: 'Another Ada',
        contact: 'Ada@Example.com', // same contact, different casing
        password: 'differentpw',
      ),
      throwsA(isA<AuthException>()),
    );
  });

  test('login succeeds with correct credentials', () async {
    await AuthRepository.instance.signUp(
      name: 'Chidi O',
      contact: 'chidi@example.com',
      password: 'password123',
    );
    await AuthRepository.instance.logOut();

    final account = await AuthRepository.instance.logIn(
      contact: 'chidi@example.com',
      password: 'password123',
    );

    expect(account.name, 'Chidi O');
    expect(AuthRepository.instance.isLoggedIn, isTrue);
  });

  test('login fails with the wrong password', () async {
    await AuthRepository.instance.signUp(
      name: 'Chidi O',
      contact: 'chidi2@example.com',
      password: 'password123',
    );
    await AuthRepository.instance.logOut();

    expect(
      () => AuthRepository.instance.logIn(
        contact: 'chidi2@example.com',
        password: 'wrongpassword',
      ),
      throwsA(isA<AuthException>()),
    );
    expect(AuthRepository.instance.isLoggedIn, isFalse);
  });

  test('logout clears the persisted session', () async {
    await AuthRepository.instance.signUp(
      name: 'Nkem T',
      contact: 'nkem@example.com',
      password: 'password123',
    );
    expect(AuthRepository.instance.isLoggedIn, isTrue);

    await AuthRepository.instance.logOut();

    expect(AuthRepository.instance.isLoggedIn, isFalse);
    expect(AuthRepository.instance.currentContact, isNull);
  });

  test('passwords are stored as a salted hash, never in plaintext', () async {
    final account = await AuthRepository.instance.signUp(
      name: 'Secure User',
      contact: 'secure@example.com',
      password: 'hunter22',
    );

    expect(account.passwordHash, isNot('hunter22'));
    expect(account.salt, isNotEmpty);
    expect(
      AuthRepository.instance.hashPassword('hunter22', account.salt),
      account.passwordHash,
    );

    // Same password with a different salt must hash differently.
    expect(
      AuthRepository.instance.hashPassword('hunter22', 'different-salt'),
      isNot(account.passwordHash),
    );
  });

  test('login fails for an account that does not exist', () async {
    expect(
      () => AuthRepository.instance.logIn(
        contact: 'ghost@example.com',
        password: 'whatever',
      ),
      throwsA(isA<AuthException>()),
    );
  });
}
