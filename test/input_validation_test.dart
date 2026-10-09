import 'package:flutter_test/flutter_test.dart';

bool isValidEmail(String email) {
  if (email.isEmpty) return false;
  final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  return emailRegex.hasMatch(email);
}

bool isValidPassword(String password) {
  return password.length >= 6;
}

bool isValidPhone(String phone) {
  final clean = phone.replaceAll(RegExp(r'[\s-]'), '');
  // Philippine mobile numbers: 09XXXXXXXXX or +639XXXXXXXXX
  final phoneRegex = RegExp(r'^(\+639\d{9}|09\d{9})$');
  return phoneRegex.hasMatch(clean);
}

bool isValidStatusTransition(String currentStatus, String targetStatus) {
  const validTransitions = {
    'available': ['pending', 'available'],
    'pending': ['approved', 'rejected', 'available'],
    'approved': ['adopted', 'available'],
    'adopted': <String>[],
  };

  return validTransitions[currentStatus]?.contains(targetStatus) ?? false;
}

void main() {
  group('Adopter Registration & Input Validation Tests', () {
    test('Valid email addresses pass regex verification', () {
      expect(isValidEmail('adopter@gmail.com'), isTrue);
      expect(isValidEmail('jalrg.staff@bohol.org'), isTrue);
      expect(isValidEmail('juan.delacruz123@yahoo.com.ph'), isTrue);
    });

    test('Malformed email addresses are rejected', () {
      expect(isValidEmail(''), isFalse);
      expect(isValidEmail('plainaddress'), isFalse);
      expect(isValidEmail('@missinguser.com'), isFalse);
      expect(isValidEmail('user@.missingdomain'), isFalse);
      expect(isValidEmail('user@domain'), isFalse);
    });

    test('Password must be at least 6 characters in length', () {
      expect(isValidPassword('12345'), isFalse);
      expect(isValidPassword(''), isFalse);
      expect(isValidPassword('123456'), isTrue);
      expect(isValidPassword('StrongPass2026!'), isTrue);
    });

    test('Philippine contact phone numbers match valid national formats', () {
      expect(isValidPhone('09171234567'), isTrue);
      expect(isValidPhone('0920 987 6543'), isTrue);
      expect(isValidPhone('+63918-123-4567'), isTrue);
      expect(isValidPhone('12345'), isFalse);
      expect(isValidPhone('08123456789'), isFalse);
    });
  });

  group('Adoption Application State Machine Tests', () {
    test('Available pets can move to pending status upon application', () {
      expect(isValidStatusTransition('available', 'pending'), isTrue);
    });

    test('Pending applications can transition to approved or rejected', () {
      expect(isValidStatusTransition('pending', 'approved'), isTrue);
      expect(isValidStatusTransition('pending', 'rejected'), isTrue);
    });

    test('Approved applications can transition to adopted', () {
      expect(isValidStatusTransition('approved', 'adopted'), isTrue);
    });

    test('Adopted pet is a terminal state and cannot transition to pending', () {
      expect(isValidStatusTransition('adopted', 'pending'), isFalse);
      expect(isValidStatusTransition('adopted', 'approved'), isFalse);
    });
  });
}
