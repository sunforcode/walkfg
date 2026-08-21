import 'package:flutter_test/flutter_test.dart';
import 'package:walk/model/trip/trip_model.dart';

void main() {
  test('serializes private trip privacy setting using backend integer code', () {
    final trip = TripModel(
      id: '',
      name: '测试行程',
      description: '',
      startDate: DateTime.fromMillisecondsSinceEpoch(1787313600000),
      endDate: DateTime.fromMillisecondsSinceEpoch(1787400000000),
      status: TripStatus.planning,
      routeIds: const ['route-1'],
      primaryRouteId: 'route-1',
      participantCount: 1,
      organizerId: 'current_user',
      privacySetting: 'private',
    );

    final json = trip.toJson();
    expect(json['privacy_setting'], 2);
    expect(json['start_date'], 1787313600);
    expect(json['end_date'], 1787400000);
  });

  test('keeps backend privacy string when parsing trip response', () {
    final trip = TripModel.fromJson({
      'id': 'trip-1',
      'name': '测试行程',
      'description': '',
      'start_date': 1787313600,
      'end_date': 1787400000,
      'status': 0,
      'route_ids': ['route-1'],
      'participant_count': 1,
      'organizer_id': 'current_user',
      'privacy_setting': 'private',
    });

    expect(trip.privacySetting, 'private');
  });
}
