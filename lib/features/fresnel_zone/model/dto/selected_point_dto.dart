class SelectedPointDto {
  
  double d1 = 0.0;
  double d2 = 0.0;
  double? elevationOfProfile;
  double heightAboveSeaLevel = 0.0;

  SelectedPointDto({required this.d1, required this.d2, this.elevationOfProfile, required this.heightAboveSeaLevel});
}