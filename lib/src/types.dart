class Location {
  final String type;
  final List<double> coordinates;

  const Location({
    this.type,
    this.coordinates,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        type: json['type'],
        coordinates: json['coordinates'],
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "coordinates": coordinates.toString(),
      };
}
