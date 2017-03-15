# Minihubot

Dockerfile for [Hubot](https://hubot.github.com) using irc adapter. Used for #minishift.

<!-- MarkdownTOC -->

- [Base Docker Image](#base-docker-image)
- [Usage](#usage)
	- [Build](#build)
	- [Run](#run)
- [Develop](#develop)
	- [Testing webhooks](#testing-webhooks)

<!-- /MarkdownTOC -->

<a name="base-docker-image"></a>
## Base Docker Image

- node:7.5.0

<a name="usage"></a>
## Usage

<a name="build"></a>
### Build

```
$ docker build -t minishift/minibot .
```

<a name="run"></a>
### Run

```
$ docker run -rm -p 9009:9009 -e HUBOT_AUTH_ADMIN=<comma seperated nics> -e HUBOT_IRC_PASSWORD=<password> -e REDISTOGO_URL=<redis-url> -t minishift/minibot
```

<a name="develop"></a>
## Develop

To develop locally you can let the bot connect to a test room:

    $ docker run --rm -p 9009:9009 -e HUBOT_IRC_ROOMS=#foo -e HUBOT_AUTH_ADMIN=<comma seperated nics> -e HUBOT_IRC_PASSWORD=<password> -e REDISTOGO_URL=<redis-url> -t minishift/minibot


<a name="testing-webhooks"></a>
### Testing webhooks

To test a webhook, execute the following against your local instance of the bot:

    $ curl http://<ip>:9009/hubot/<hook> --data-urlencode payload@<file>

where:

* \<ip\> is the IP of your Docker daemon
* \<hook\> is the defined webhook endpoint
* \<file\> is the filename of the file containing the JSON payload
