# Crée un repository ECR pour stocker notre image Docker
resource "aws_ecr_repository" "weather_app" {
  name                 = "demo-weather-app"
  image_tag_mutability = "MUTABLE"  # permet d'écraser les tags existants

  # Active le scan automatique des vulnérabilités
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "demo-weather-app"
  }
}

# Affiche l'URL du repository à la fin
output "ecr_repository_url" {
  value = aws_ecr_repository.weather_app.repository_url
}