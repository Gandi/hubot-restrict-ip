Hubot Restrict IP Plugin
=================================

[![Version](https://img.shields.io/npm/v/hubot-restrict-ip.svg)](https://www.npmjs.com/package/hubot-restrict-ip)
[![Downloads](https://img.shields.io/npm/dt/hubot-restrict-ip.svg)](https://www.npmjs.com/package/hubot-restrict-ip)
[![Build Status](https://img.shields.io/travis/Gandi/hubot-restrict-ip.svg)](https://travis-ci.org/Gandi/hubot-restrict-ip)
[![Dependency Status](https://gemnasium.com/Gandi/hubot-restrict-ip.svg)](https://gemnasium.com/Gandi/hubot-restrict-ip)
[![Coverage Status](https://img.shields.io/codeclimate/coverage/github/Gandi/hubot-restrict-ip.svg)](https://codeclimate.com/github/Gandi/hubot-restrict-ip/coverage)
[![Code Climate](https://img.shields.io/codeclimate/github/Gandi/hubot-restrict-ip.svg)](https://codeclimate.com/github/Gandi/hubot-restrict-ip)

This plugin is an Express middleware that will permit to filter who has access to the http endpoints of your hubot bot.



Installation
--------------
In your hubot directory:    

    npm install hubot-restrict-ip --save

Then add `hubot-restrict-ip` to `external-scripts.json`


Configuration
-----------------

- `HTTP_RESTRICTED` if set, protects all express endpoints by default, only the open_endpoints are reachable by everybody, and the ip_whitelist
- `HTTP_IP_WHITELIST` only useful when HTTP_RESTRICTED is set
- `HTTP_IP_BLACKLIST` overwrite the whitelist if HTTP_RESTRICTED is set, and blocks ips listed anyways if not
- `HTTP_OPEN_ENDPOINTS` over-rules any other configuration to keep those endpoints open
- `HTTP_CLOSED_ENDPOINTS` if HTTP_RESTRICTED is set and HTTP_OPEN_ENDPOINTS are contradicted by HTTP_CLOSED_ENDPOINTS, the closed one wins.
- `HTTP_UNAUTHORIZED_MESSAGE` the message provided with the `401` status triggered when access is restricted by any rule.

With

- The IP lists are separated by `,` commas, and use CIDR for range definition like `192.168.0.0/24`. IP can also be IPv6 ranges.
- the endpoints are a list of endpoints, separated by commas too, like `/hubot/help` but it can also be a regexp like `/.*/help`

Testing
----------------

    npm install

    # will run make test and coffeelint
    npm test 
    
    # or
    make test
    
    # or, for watch-mode
    make test-w

    # or for more documentation-style output
    make test-spec

    # and to generate coverage
    make test-cov

    # and to run the lint
    make lint

    # run the lint and the coverage
    make

Changelog
---------------
All changes are listed in the [CHANGELOG](CHANGELOG.md)

Contribute
--------------
Feel free to open a PR if you find any bug, typo, want to improve documentation, or think about a new feature. 

Gandi loves Free and Open Source Software. This project is used internally at Gandi but external contributions are **very welcome**. 

Authors
------------
- [@mose](https://github.com/mose) - author and maintainer

License
-------------
This source code is available under [MIT license](LICENSE).

Copyright
-------------
Copyright (c) 2016 - Gandi - https://gandi.net
