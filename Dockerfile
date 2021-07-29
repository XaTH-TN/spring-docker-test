## syntax=docker/dockerfile:1
#
#FROM openjdk:16-alpine3.13
#
#WORKDIR /app
#
#COPY .mvn/ .mvn
#COPY mvnw pom.xml ./
#RUN dos2unix mvnw && ./mvnw dependency:go-offline
#
#COPY src ./src
#
#CMD ["./mvnw", "spring-javaformat:help", "spring-javaformat:apply", "spring-boot:run", "-Dspring-boot.run.profiles=mysql"]
# syntax=docker/dockerfile:1

# syntax=docker/dockerfile:1

FROM openjdk:16-alpine3.13 as base

WORKDIR /app

COPY .mvn/ .mvn
COPY mvnw pom.xml ./
RUN chmod +x mvnw && dos2unix mvnw && ./mvnw dependency:go-offline
COPY src ./src

FROM base as test
RUN ["./mvnw", "spring-javaformat:apply", "test"]

FROM base as development
CMD ["./mvnw", "spring-javaformat:apply", "spring-boot:run", "-Dspring-boot.run.profiles=mysql", "-Dspring-boot.run.jvmArguments='-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:8000'"]

FROM base as build
RUN ./mvnw package

FROM openjdk:11-jre-slim as production
EXPOSE 8080

COPY --from=build /app/target/spring-petclinic-*.jar /spring-petclinic.jar

CMD ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "/spring-petclinic.jar"]
