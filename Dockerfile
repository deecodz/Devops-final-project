FROM maven:3.8.3-openjdk-11 AS build

# Create working dir
WORKDIR /app

# Copy the source code and pom.xml to the container
COPY ./ /app

# Build the Maven project
RUN mvn clean package

FROM tomcat:9.0.75-jdk11-corretto-al2

# Copy the built JAR file from the previous stage
COPY --from=build /app/target/WebAppCal-1.3.5.war /usr/local/tomcat/webapps/

# Expose the Tomcat port
EXPOSE 8080

# Start Tomcat when the container starts
CMD ["catalina.sh", "run"]

