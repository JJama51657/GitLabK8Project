FROM maven:3.9.9-eclipse-temurin-21-jammy AS build_image
COPY . /app
WORKDIR /app
RUN mvn install


FROM tomcat:10-jdk21

RUN rm -rf /usr/local/tomcat/webapps/*

COPY --from=build_image /app/target/vprofile-v2.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]
