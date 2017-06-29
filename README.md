# Minibot

Dockerfile for a custom [Hubot](https://hubot.github.com) called Minibot.
Minibot is a IRC bot employed by the [Minishift team](https://github.com/orgs/minishift/teams/minishift-dev/members) to work on the #minishift channel on irc.freenode.net.

<!-- MarkdownTOC -->

- [Usage](#usage)
	- [Minishift stand-ups](#minishift-stand-ups)
	- [Sprint backlog](#sprint-backlog)
	- [CI notifications](#ci-notifications)
- [Developing](#developing)
	- [Building the image](#building-the-image)
	- [Running the image](#running-the-image)
	- [Testing webhooks](#testing-webhooks)
- [Resources](#resources)

<!-- /MarkdownTOC -->

<a name="usage"></a>
## Usage

<a name="minishift-stand-ups"></a>
### Minishift stand-ups

Minibot drives the daily stand-ups of the Minishift team on #minishift on irc.freenode.net.
For this it utilizes the [hubot-standup](https://github.com/miyagawa/hubot-standup) plugin.

In order to add and remove users to the stand-up [hubot-auth](https://github.com/hubot-scripts/hubot-auth) is used.

To add a user to the stand-ups:

    minibot <user> has a minishift member role

To remove a user from the stand-ups:

    minibot <user> doesn’t have a minishift member role

To list the roles of a user:

    minibot what roles does <user> have

<a name="sprint-backlog"></a>
### Sprint backlog

Sprint backlogs in comma separated format can be added to Minibot brain via a webhook:

    curl -X POST http://<IP>:9009/hubot/sprint -d sprint=134 -d data="$(cat sprint-134.csv)"

Once uploaded the backlog can be printed via the Minibot command:

    minibot print sprint <id>

 An issue can be marked as completed by:

    minibot mark issue <issue-id> of sprint <sprint-id> completed

 To see which sprints Minibot knows about:

    minibot list known sprints

<a name="ci-notifications"></a>
### CI notifications

At the moment only one of the used CI build servers used by the Minishift sends notifications to Minibot, namely [Travis CI](https://travis-ci.org/minishift/minishift).
The required webhook is configured [here](https://github.com/minishift/minishift/blob/master/.travis.yml).

<a name="developing"></a>
## Developing

<a name="building-the-image"></a>
### Building the image

    $ docker build -t minishift/minibot .

<a name="running-the-image"></a>
### Running the image

    $ docker run -rm -p 9009:9009 \
    -e HUBOT_AUTH_ADMIN=<comma seperated nics> \
    -e HUBOT_IRC_PASSWORD=<password> \
    -e REDISTOGO_URL=<redis-url> \
    -t minishift/minibot

To develop locally you can let the bot connect to a test room:

    $ docker run --rm -p 9009:9009 -e HUBOT_IRC_ROOMS=#foo -e HUBOT_AUTH_ADMIN=<comma separated nics> -e HUBOT_IRC_PASSWORD=<password> -e REDISTOGO_URL=<redis-url> -t minishift/minibot

<a name="testing-webhooks"></a>
### Testing webhooks

To test a webhook, execute the following against your local instance of the bot:

    $ curl http://<ip>:9009/hubot/<hook> --data-urlencode payload@<file>

where:

* \<ip\> is the IP of your Docker daemon
* \<hook\> is the defined webhook endpoint
* \<file\> is the filename of the file containing the JSON payload

<a name="resources"></a>
## Resources

* [Hubot Documentation](https://hubot.github.com/docs/patterns/)
