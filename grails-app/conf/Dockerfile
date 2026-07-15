FROM gradle:8.8-jdk17 AS build
WORKDIR /app
 
COPY . .

RUN chmod +x ./gradlew
 
 
RUN ./gradlew bootJar
From eclipse-temurin:17-jre-alpine AS runtime

 
ENV JAVA_OPTS="-XX:InitialRAMPercentage=50.0 -XX:MaxRAMPercentage=75.0"
COPY --from=build app/build/libs/*.jar app/app.jar
 
 
WORKDIR app
 
USER 10014
 


EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]