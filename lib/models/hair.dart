/// MODELO
///
/// El pelo de un usuario de https://dummyjson.com/users
/// Dentro del JSON del usuario viene como un objeto propio:
///
///   "hair": { "color": "Brown", "type": "Curly" }
///
/// Por eso tiene su propia clase en vez de aplanarlo dentro de User: si el
/// JSON tiene un objeto, nosotros tenemos una clase. Cada trozo de la
/// respuesta sabe convertirse a sí mismo y User solo delega.
///
/// De regalo: `hairColorsProvider` y el filtro trabajan con `Hair.color`, un
/// sitio único donde mirar si mañana la API añade "hair.length".
class Hair {
  final String color;
  final String type;

  const Hair({required this.color, required this.type});

  factory Hair.fromJson(Map<String, dynamic> json) {
    return Hair(
      color: json['color'] as String? ?? '',
      type: json['type'] as String? ?? '',
    );
  }
}
