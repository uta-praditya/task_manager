import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/features/auth/data/models/user_model.dart';

void main() {
  const testUser = UserModel(
    id: '1',
    email: 'test@example.com',
    name: 'Test User',
  );

  group('UserModel', () {
    test('should create user with all properties', () {
      expect(testUser.id, '1');
      expect(testUser.email, 'test@example.com');
      expect(testUser.name, 'Test User');
    });

    test('should convert to JSON correctly', () {
      final json = testUser.toJson();
      
      expect(json['id'], '1');
      expect(json['email'], 'test@example.com');
      expect(json['name'], 'Test User');
    });

    test('should create from JSON correctly', () {
      final json = {
        'id': '1',
        'email': 'test@example.com',
        'name': 'Test User',
      };

      final user = UserModel.fromJson(json);
      
      expect(user.id, '1');
      expect(user.email, 'test@example.com');
      expect(user.name, 'Test User');
    });
  });
}