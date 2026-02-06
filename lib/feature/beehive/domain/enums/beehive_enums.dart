enum ActivityLevel {
  alta('Alta'),
  media('Media'),
  baja('Baja');

  final String value;
  const ActivityLevel(this.value);
}

enum BeePopulation {
  alta('Alta'),
  media('Media'),
  baja('Baja');

  final String value;
  const BeePopulation(this.value);
}

enum HiveStatus {
  camaraDeCriaYProduccion('Cámara de cría y producción'),
  camaraDeCriaYDobleAlzaDeProduccion(
    'Cámara de cría y doble alza de producción',
  ),
  camaraDeCria('Cámara de cría'),
  camaraDeProduccion('Cámara de producción');

  final String value;
  const HiveStatus(this.value);
}

enum HealthStatus {
  ninguno('Ninguno'),
  presenciaBarroa('Presencia barroa'),
  presenciaDePlagas('Presencia de plagas'),
  enfermedad('Enfermedad');

  final String value;
  const HealthStatus(this.value);
}

enum HasProductionChamber {
  si('Si'),
  no('No');

  final String value;
  const HasProductionChamber(this.value);
}
