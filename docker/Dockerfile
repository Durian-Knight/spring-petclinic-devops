# syntax=docker/dockerfile:1

# ---- Build stage -----------------------------------------------------------
FROM eclipse-temurin:17-jdk-jammy AS build
WORKDIR /workspace

# Cache dependencies separately from source for faster rebuilds
COPY mvnw pom.xml ./
COPY .mvn/ .mvn/
RUN --mount=type=cache,target=/root/.m2 ./mvnw -B dependency:go-offline

COPY src/ src/
RUN --mount=type=cache,target=/root/.m2 ./mvnw -B -DskipTests package \
    && mv target/*.jar target/app.jar

# ---- Runtime stage ----------------------------------------------------------
FROM eclipse-temurin:17-jre-jammy
LABEL org.opencontainers.image.source="https://github.com/Durian-Knight/spring-petclinic-devops"
LABEL org.opencontainers.image.description="Spring PetClinic - containerized for CI/CD/K8s demo"

RUN groupadd --system spring && useradd --system --gid spring spring
WORKDIR /app
COPY --from=build /workspace/target/app.jar app.jar
RUN chown spring:spring app.jar
USER spring

EXPOSE 8080
ENV SPRING_PROFILES_ACTIVE=mysql \
    JAVA_OPTS=""

HEALTHCHECK --interval=15s --timeout=5s --start-period=45s --retries=5 \
    CMD wget -qO- http://localhost:8080/actuator/health | grep -q '"status":"UP"' || exit 1

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
