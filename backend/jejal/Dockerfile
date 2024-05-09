# 빌드 스테이지
FROM gradle:8.7-jdk17 AS build
COPY --chown=gradle:gradle . /home/gradle/src
WORKDIR /home/gradle/src
RUN gradle build --no-daemon

# 패키지 스테이지
FROM openjdk:17-jdk-alpine
EXPOSE 443
COPY --from=build /home/gradle/src/build/libs/JeJal-0.0.1-SNAPSHOT.jar /app.jar
ENTRYPOINT ["java", "-jar", "/app.jar"]