FROM debian:bookworm-slim

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV JAVA_HOME_8=/usr/lib/jvm/temurin-8-jdk-amd64
ENV JAVA_HOME_17=/usr/lib/jvm/temurin-17-jdk-amd64
ENV JAVA_HOME_21=/usr/lib/jvm/temurin-21-jdk-amd64

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
    wget \
    gnupg \
    software-properties-common \
    curl \
    unzip \
    vim \
    procps \
    git \
    && rm -rf /var/lib/apt/lists/*

# Add Adoptium repository for Temurin JDK
RUN wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | apt-key add - && \
    echo "deb https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | tee /etc/apt/sources.list.d/adoptium.list

# Install multiple Java versions
RUN apt-get update && \
    apt-get install -y \
    temurin-8-jdk \
    temurin-17-jdk \
    temurin-21-jdk \
    && rm -rf /var/lib/apt/lists/*

# Create a script to switch between Java versions
RUN echo '#!/bin/bash\n\
if [ "$1" = "8" ]; then\n\
  export JAVA_HOME=$JAVA_HOME_8\n\
elif [ "$1" = "17" ]; then\n\
  export JAVA_HOME=$JAVA_HOME_17\n\
elif [ "$1" = "21" ]; then\n\
  export JAVA_HOME=$JAVA_HOME_21\n\
else\n\
  echo "Usage: source setjava [8|17|21]"\n\
  return 1\n\
fi\n\
export PATH=$JAVA_HOME/bin:$PATH\n\
java -version\n\
echo "Java $1 is now active"\n\
' > /usr/local/bin/setjava && chmod +x /usr/local/bin/setjava

# Create a script to create symbolic links to set default Java version
RUN echo '#!/bin/bash\n\
if [ "$1" = "8" ]; then\n\
  update-alternatives --set java $JAVA_HOME_8/bin/java\n\
  update-alternatives --set javac $JAVA_HOME_8/bin/javac\n\
elif [ "$1" = "17" ]; then\n\
  update-alternatives --set java $JAVA_HOME_17/bin/java\n\
  update-alternatives --set javac $JAVA_HOME_17/bin/javac\n\
elif [ "$1" = "21" ]; then\n\
  update-alternatives --set java $JAVA_HOME_21/bin/java\n\
  update-alternatives --set javac $JAVA_HOME_21/bin/javac\n\
else\n\
  echo "Usage: setdefaultjava [8|17|21]"\n\
  exit 1\n\
fi\n\
java -version\n\
echo "Default Java set to version $1"\n\
' > /usr/local/bin/setdefaultjava && chmod +x /usr/local/bin/setdefaultjava

# Set Java 21 as default
RUN /usr/local/bin/setdefaultjava 21

# Set up working directory
WORKDIR /app

# Default to bash shell
CMD ["/bin/bash"]