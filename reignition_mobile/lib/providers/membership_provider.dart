import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reignition_core/reignition_core.dart';

final membershipServiceProvider = Provider<MembershipService>((ref) => MembershipService());

final myMembershipsProvider = FutureProvider.autoDispose<List<MembershipResponse>>((ref) async {
  return ref.read(membershipServiceProvider).getMyMemberships();
});
