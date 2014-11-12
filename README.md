# Minihubot

Dockerfile for [Hubot](https://hubot.github.com) using irc adapter. Used for #minishift.

<!-- MarkdownTOC -->

- [Base Docker Image](#base-docker-image)
- [Usage](#usage)
	- [Build](#build)
	- [Run](#run)

<!-- /MarkdownTOC -->

<a name="base-docker-image"></a>
### Base Docker Image

- node:7.5.0

<a name="usage"></a>
### Usage

<a name="build"></a>
#### Build

```
$ docker build -t hferentschik/hubot .
```

<a name="run"></a>
#### Run

```
$ docker run -e HUBOT_AUTH_ADMIN=<comma seperated nics> -e HUBOT_IRC_PASSWORD=<password> -e ENV REDISTOGO_URL=<redis-url> -t hferentschik/hubot
```
