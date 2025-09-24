FROM openjdk:17

LABEL version=0.1

ARG JAR_NAME=code-0.0.1-SNAPSHOT.jar
ARG SPRING_PROFILE=prod

ARG JAR_PATH=./build/libs/${JAR_NAME}

RUN mkdir -p /app

WORKDIR /app

COPY ${JAR_PATH} /app/app.jar

CMD ["sh", "-c", "java -jar -Dspring.profiles.active=${SPRING_PROFILE} /app/app.jar"]