FROM openjdk:17-bullseye

WORKDIR /app

COPY build/libs/sprintboot.jar /app/springboot.jar
COPY githubActions/entrypoint.sh /app/entrypoint.sh

RUN chmod +x /app/entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/app/entrypoint.sh"]