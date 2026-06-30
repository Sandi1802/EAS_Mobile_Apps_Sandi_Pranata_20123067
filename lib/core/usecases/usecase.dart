import '../error/failures.dart';

// Jika tidak pakai dartz, kita bisa buat custom class Result. 
// Saya akan menggunakan class record bawaan Dart 3.

abstract class UseCase<Type, Params> {
  Future<(Failure?, Type?)> call(Params params);
}

class NoParams {}
