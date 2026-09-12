# Étape 1 : Build de l'application
# On utilise Maven pour compiler le projet
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# Étape 2 : Image finale
# On prend juste le JAR compilé, sans Maven
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar

# Port exposé par l'application
EXPOSE 8086

# Commande de lancement
ENTRYPOINT ["java", "-jar", "app.jar"]
