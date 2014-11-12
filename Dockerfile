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
RUN npm install hubot coffee-script redis irc && \
    npm install hubot-standup --save && \
    npm install hubot-auth --save && \
    npm install nodepie underscore xml2js cron emailjs sugar --save && \
    npm install generator-hubot

# Create Hubot
RUN ~/.npm/bin/yo hubot --owner="Minishift Team" --name="Minibot" --description="Minishift IRC Hubot" --defaults

# Set environment variables
ENV TZ Europe/Stockholm

ENV HUBOT_IRC_NICK minibot
ENV HUBOT_IRC_USERNAME minibot
ENV HUBOT_IRC_ROOMS #minishift
ENV HUBOT_IRC_SERVER irc.freenode.net
ENV HUBOT_IRC_UNFLOOD true
ENV HUBOT_JIRA_DOMAIN issues.jboss.org
ENV HUBOT_JIRA_PROJECTS CDK
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
