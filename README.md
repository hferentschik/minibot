# Minibot

Minibot is a IRC bot employed by the [Minishift team](https://github.com/orgs/minishift/teams/minishift-dev/members) to work on the #minishift channel on irc.freenode.net.

<!-- MarkdownTOC -->

- [Usage](#usage)
    - [Minishift stand-ups](#minishift-stand-ups)
    - [Archaeologist](#archaeologist)
    - [Sprint backlog](#sprint-backlog)
    - [CentOS CI](#centos-ci)
    - [CI notifications](#ci-notifications)
    - [Misc](#misc)
- [Developing](#developing)
    - [Building the Minibot image](#building-the-minibot-image)
    - [Running the Minibot image](#running-the-minibot-image)
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

<a name="archaeologist"></a>
### Archaeologist

The archaeologist is a role within the Minishift time who has the task to groom long standing issues.
The role rotates amongst the core devs of the Minishift team and usually is held for a week (number of days are configurable via `MINIBO_ARCHAEOLOGIST_DAYS`).
Minibot offers several commands to aid keeping track of the current archaeologist.
Per default the current archaeologist is called out after a [stand-up](#minishift-stand-ups).
However, there are also several commands to explicitly manage the archaeologist role.

Add a user to the list of archaeologists:

    minibot <user> has an archaeologist member role

To remove a user from the list of archaeologists:

    minibot <user> doesn’t an archaeologist member role

To print the current archaeologist:

    minibot who is archaeologist

To skip to the next archaeologist:

    minibot archaeologist next

For all supported commands

    minibot archaeologist?

<a name="sprint-backlog"></a>
### Sprint backlog

Sprint backlogs in comma separated format can be added to Minibot brain via a webhook:

    $ curl -X POST http://<IP>:9009/hubot/sprint -d sprint=134 -d data="$(cat sprint-134.csv)"

Once uploaded the backlog can be printed via the Minibot command:

    minibot print sprint <id>

 An issue can be marked as completed by:

    minibot mark issue <issue-id> of sprint <sprint-id> completed

 To see which sprints Minibot knows about:

    minibot list known sprints

<a name="centos-ci"></a>
### CentOS CI

You can ask for the latest master build artifacts built by CentOS CI:

    minibot latest master artifacts

Or you can ask for pull request artifacts:

    minibot artifacts for pr <pr-id>

<a name="ci-notifications"></a>
### CI notifications

At the moment [Travis CI](https://travis-ci.org/minishift/minishift), [AppVeyor](https://www.appveyor.com) and [Circle CI](https://circleci.com) send notifications to Minibot.
The required webhooks are configured in [.travis.yml](https://github.com/minishift/minishift/blob/master/.travis.yml), [appveyor.yml](https://github.com/minishift/minishift/blob/master/appveyor.yml) resp. [circle.yml](https://github.com/minishift/minishift/blob/master/circle.yml) in the Minishift [repository](https://github.com/minishift/minishift).

<a name="misc"></a>
### Misc

Other than that the following hubot scripts are installed:

* [hubot-timezone](https://github.com/ryandao/hubot-timezone)
* [hubot-good-karma](https://www.npmjs.com/package/hubot-good-karma)

<a name="developing"></a>
## Developing

In order to develop on Minibot you need to set the environment variables `MINIBOT_REDIS_URL` and `MINIBOT_IRC_PASS`.

<a name="building-the-minibot-image"></a>
### Building the Minibot image

    $ make build

<a name="running-the-minibot-image"></a>
### Running the Minibot image

    $ make run

<a name="testing-webhooks"></a>
### Testing webhooks

The [testdata](https://github.com/minishift/minibot/tree/master/testdata) directory contains some sample JSON payload files to test the Minibot webhook integration.
To test a webhook, execute the following against your local instance of Minibot:

    $ cd testdata
    $ curl http://<IP>:9009/hubot/travis-ci --data-urlencode payload@travis-ci.json
    # or
    $ curl http://<IP>:9009/hubot/circleci -H "Content-Type: application/json" -d @circleci.json
    # or
    $ curl http://<IP>:9009/hubot/appveyor -H "Content-Type: application/json" -d @appveyor.json

where:

* \<IP\> is the IP of your Docker daemon

To test the CentOS CI release webhook, execute:

    $ curl http://<IP>:9009/hubot/centosci -H "Content-Type: application/json" -d '{"payload":{"status":"success","message":"Minishift v1.0.0 successfully released by https://ci.centos.org/job/minishift-release/100","url":"https://github.com/minishift/minishift/releases/tag/v1.0.0"}}'

<a name="resources"></a>
## Resources

* [Hubot Documentation](https://hubot.github.com/docs/patterns/)
