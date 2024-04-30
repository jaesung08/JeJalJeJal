# 빌드 스테이지
FROM gradle:8.7-jdk17 AS build
LABEL authors="JaeSung"
COPY --chown=gradle:gradle . /home/gradle/src
WORKDIR /home/gradle/src
RUN gradle build --no-daemon

# 패키지 스테이지
FROM openjdk:17-jdk-alpine
COPY --from=build /home/gradle/src/build/libs/*.jar /app.jar
ENTRYPOINT ["java","-jar","/app.jar"]