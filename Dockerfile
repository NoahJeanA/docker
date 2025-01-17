FROM openjdk:8

WORKDIR /opt/forge
ARG SERVER_VERSION=1.12.2-14.23.5.2859
ARG INSTALLER_JAR=forge-${SERVER_VERSION}-installer.jar
ARG SERVER_JAR=forge-${SERVER_VERSION}.jar

RUN apt update && \
    apt install -y wget && \
    wget https://maven.minecraftforge.net/net/minecraftforge/forge/1.12.2-14.23.5.2859/$INSTALLER_JAR && \
    java -jar $INSTALLER_JAR --installServer && \
    rm -f /opt/forge/INSTALLER_JAR /opt/forge/*.log && \
    java -jar ${SERVER_JAR} && \
    echo "eula=true" > eula.txt
    

 