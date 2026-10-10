import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  const AppUser({required this.uid, this.email});

  final String uid;
  final String? email;

  @override
  List<Object?> get props => [uid, email];
}
