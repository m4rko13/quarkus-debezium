# --- Build Stage ---
FROM maven:3.9.6-eclipse-temurin-21 AS build
WORKDIR /project
COPY . .
RUN mvn clean package -DskipTests

# --- Runtime Stage ---
FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=build /project/target/quarkus-app/lib/ /app/lib/
COPY --from=build /project/target/quarkus-app/*.jar /app/
COPY --from=build /project/target/quarkus-app/app/ /app/app/
COPY --from=build /project/target/quarkus-app/quarkus/ /app/quarkus/
EXPOSE 8080
CMD ["java", "-jar", "/app/quarkus-run.jar"]
