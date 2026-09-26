/// Static reference schedule for the Abuja Light Rail (Green + Blue line
/// segments currently in service). Departure times are approximate
/// published schedules; the in-app note always tells riders to confirm
/// locally since informal service changes are common.
class LightRailStation {
  final String name;
  final String note;
  const LightRailStation(this.name, {this.note = ''});
}

class LightRailLine {
  final String name;
  final String color;
  final List<LightRailStation> stations;
  final List<String> weekdayDepartures;
  final List<String> weekendDepartures;
  final double fare;

  const LightRailLine({
    required this.name,
    required this.color,
    required this.stations,
    required this.weekdayDepartures,
    required this.weekendDepartures,
    required this.fare,
  });
}

final List<LightRailLine> lightRailLines = [
  const LightRailLine(
    name: 'Abuja Light Rail — Idu to Airport Junction',
    color: 'green',
    fare: 300,
    stations: [
      LightRailStation('Idu Station'),
      LightRailStation('Kagini Station'),
      LightRailStation('Sauka Station'),
      LightRailStation('Airport Junction Station'),
    ],
    weekdayDepartures: ['06:00', '08:00', '10:00', '13:00', '16:00', '18:30'],
    weekendDepartures: ['08:00', '12:00', '16:00'],
  ),
  const LightRailLine(
    name: 'Abuja Light Rail — Airport Junction to Metro Central (Stadium)',
    color: 'blue',
    fare: 350,
    stations: [
      LightRailStation('Airport Junction Station'),
      LightRailStation('Gudu Station'),
      LightRailStation('Metro Central (Stadium) Station'),
    ],
    weekdayDepartures: ['06:30', '09:00', '11:30', '14:00', '17:00', '19:00'],
    weekendDepartures: ['09:00', '13:00', '17:00'],
  ),
];
