# Stage 1: Build stage
FROM maven:3.8.4-openjdk-11-slim AS build-stage
# Set the working directory inside the container
WORKDIR /app
# Copy the Maven project defini on files
COPY pom.xml /app/pom.xml
# Download the dependencies needed for the build (cache them in a separate layer)
RUN mvn dependency:go-offline
# Copy the applica on source code
COPY ./src /app/src
#copy ./se ngscopy.xml /app/se ngs.xml
# Build the WAR file
RUN mvn package

#Run mvn -U deploy -s se ngs.xml
# Stage 2: Produc on stage
FROM tomcat:8.5.78-jdk11-openjdk-slim
# Copy the built WAR file from the build stage to the Tomcat webapps directory
COPY --from=build-stage /app/target/*.war /usr/local/tomcat/webapps/
# Expose the port on which Tomcat will listen (usually port 8080)
EXPOSE 8080
# Start Tomcat
CMD ["catalina.sh", "run"]