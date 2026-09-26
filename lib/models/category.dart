/// MODELO
///
/// Representa una categoría de https://dummyjson.com/products/categories
/// El JSON viene así: { "slug": "beauty", "name": "Beauty", "url": "..." }
///
///   - slug: el identificador que se usa en la URL (lo que le mandamos a la API)
///   - name: el texto bonito que le mostramos al usuario
class Category {
  final String slug;
  final String name;

  const Category({required this.slug, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      slug: json['slug'] as String,
      name: json['name'] as String,
    );
  }
}
