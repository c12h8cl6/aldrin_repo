

FROM eclipse-temurin:21-jre-jammy
ARG RUNNER_VERSION="2.319.1"
RUN apt update && useradd -m docker

RUN apt install -y curl git jq libicu70 unzip wget xvfb xfonts-100dpi build-essential libssl-dev libffi-dev python3 python3-venv python3-dev python3-pip

# Install && Configure Google Chrome
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
RUN apt install -y ./google-chrome*.deb
RUN echo chrome-version
RUN google-chrome -version

# Install && Configure Mozilla Firefox
RUN apt install -y gpg
RUN curl -fsSL https://packages.mozilla.org/apt/repo-signing-key.gpg |  \
    gpg --dearmor --no-tty -o /etc/apt/keyrings/packages.mozilla.org.gpg > /dev/null && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/packages.mozilla.org.gpg] https://packages.mozilla.org/apt mozilla main" |  \
    tee /etc/apt/sources.list.d/packages.mozilla.org.list > /dev/null && \
    echo "Package: *\nPin: origin packages.mozilla.org\nPin-Priority: 1000\n\n" | tee /etc/apt/preferences.d/mozilla > /dev/null && \
    apt-get update -qq > /dev/null && \
    DEBIAN_FRONTEND=noninteractive apt-get install -qq firefox > /dev/null
RUN firefox -version

# Install && Configure Microsoft Edge
RUN apt-get update && apt-get install -y gnupg2
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg && \
    install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/ && \
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/edge stable main" > /etc/apt/sources.list.d/microsoft-edge-dev.list && \
    rm -f microsoft.gpg && \
    apt-get update && \
    apt-get install -y microsoft-edge-stable
RUN microsoft-edge-stable -version

ENV DISPLAY=:99

RUN apt autoremove &&  apt clean

RUN cd /home/docker && mkdir actions-runner && cd actions-runner \
    && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

RUN chown -R docker ~docker && /home/docker/actions-runner/bin/installdependencies.sh

COPY start.sh start.sh

RUN chmod +x start.sh

#WORKDIR /var/jenkins
#ENV TARGETARCH="linux-x64"
#COPY ./start.sh ./
#RUN chmod +x ./start.sh
# RUN useradd agent
# RUN chown agent ./
# RUN chown agent /opt/CTAS/*
# USER agent
# Another option is to run the agent as root.
#ENV AGENT_ALLOW_RUNASROOT="true"

USER docker
ENTRYPOINT ["./start.sh"]