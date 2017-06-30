FROM node:7.5.0

LABEL maintainer "Minishift Team"

# Install gobal packages
RUN apt-get update && apt-get install -y libicu-dev

RUN useradd -ms /bin/bash hubot
USER hubot
WORKDIR /home/hubot

# Allow to install npm as non root
RUN echo "prefix = /home/hubot/.npm" > /home/hubot/.npmrc

# Install npm packages
RUN npm install -g yo
RUN npm install hubot && \
    npm install coffee-script && \
    npm install redis && \
    npm install irc && \
    npm install hubot-standup && \
    npm install hubot-auth && \
    npm install hubot-timezone && \
    npm install nodepie && \
    npm install underscore && \
    npm install xml2js && \
    npm install cron && \
    npm install emailjs && \
    npm install sugar && \
    npm install generator-hubot && \
    npm install githubot && \
    npm install url && \
    npm install querystring && \
    npm install csv-parse && \
    npm install pad

# Create Hubot
RUN ~/.npm/bin/yo hubot --owner="Minishift Team" --name="Minibot" --description="Minishift IRC Hubot" --defaults

# Set environment variables
ENV TZ Europe/Stockholm

ENV HUBOT_IRC_NICK minibot
ENV HUBOT_IRC_USERNAME minibot
ENV HUBOT_IRC_ROOMS #minishift
ENV HUBOT_IRC_SERVER irc.freenode.net
ENV HUBOT_IRC_UNFLOOD true
#ENV HUBOT_IRC_DEBUG true

# HTTP Listener port 9009
ENV PORT 9009
EXPOSE 9009

# Add custum scripts
ADD external-scripts.json /home/hubot/external-scripts.json
ADD scripts/*.coffee /home/hubot/scripts/
ADD adapter /home/hubot/adapter

RUN npm link adapter

# Run hubot
ENTRYPOINT ["/home/hubot/bin/hubot", "-a", "irc", "--name", "minibot"]
