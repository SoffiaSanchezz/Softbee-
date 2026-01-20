class Apiary {
  final String apiaryName;
  final String location;
  // TODO: The user's code suggests a "beehives_count" field, but it's not fully implemented in the UI.
  // final int beehivesCount; 
  final bool treatments;

  const Apiary({
    required this.apiaryName,
    required this.location,
    // required this.beehivesCount,
    required this.treatments,
  });
}
