Hubot Restrict IP Plugin
=================================

[![Build Status](https://img.shields.io/travis/Gandi/hubot-restrict-ip.svg)](https://travis-ci.org/Gandi/hubot-restrict-ip)
[![Dependency Status](https://gemnasium.com/Gandi/hubot-restrict-ip.svg)](https://gemnasium.com/Gandi/hubot-restrict-ip)
[![Coverage Status](https://img.shields.io/codeclimate/coverage/github/Gandi/hubot-restrict-ip.svg)](https://codeclimate.com/github/Gandi/hubot-restrict-ip/coverage)
[![Code Climate](https://img.shields.io/codeclimate/github/Gandi/hubot-restrict-ip.svg)](https://codeclimate.com/github/Gandi/hubot-restrict-ip)

This plugin is an Express middleware that will permit to filter who has access to the http endpoints of your hubot bot.

    This is a draft plugin. DO NOT USE (yet)


Installation
--------------
In your hubot directory:    

    npm install hubot-restrict-ip --save

Then add `hubot-restrict-ip` to `external-scripts.json`


Configuration
-----------------

- `HTTP_RESTRICTED`
- `HTTP_IP_WHITELIST`
- `HTTP_IP_BLACKLIST`
- `HTTP_OPEN_ENDPOINTS`
- `HTTP_CLOSED_ENDPOINTS`
- `HTTP_UNAUTHORIZED_MESSAGE`


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
