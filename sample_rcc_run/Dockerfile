FROM ubuntu
WORKDIR /robocorp-run
RUN apt-get update
RUN apt-get install -y xvfb 
RUN apt-get install -y zip 
RUN apt-get install -y wget 
RUN apt-get install ca-certificates 
RUN apt-get update && apt-get clean && apt-get install -y \
    gnupg2 \
    x11vnc \
    xvfb \
    fluxbox \
    wmctrl \
    wget \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list \
    && apt-get update && apt-get -y install google-chrome-stable
COPY . .
RUN chmod a+x rcc
RUN mv rcc /usr/local/bin/
CMD ["rcc","run","-e","devdata/env.json","--task", "Run_Orange_HR_Process"]
