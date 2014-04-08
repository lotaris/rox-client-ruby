# Ruby ROX Client

**Utilities for [ROX Center](https://github.com/lotaris/rox-center) ruby clients.**

[![Gem Version](https://badge.fury.io/rb/rox-client-ruby.png)](http://badge.fury.io/rb/rox-client-ruby)

## Requirements

* Ruby 1.9.3 or higher

## Installation

In your Gemfile:

```rb
gem 'rox-client-ruby', '~> 0.1.0'
```

## Usage

This project is a library for ROX Center clients in Ruby.
It must be integrated into a testing framework, e.g. [rox-client-rspec](https://github.com/lotaris/rox-client-rspec) for [RSpec](https://relishapp.com/rspec).

The [Setup](#setup) procedure is common to all clients and describes how to use ROX configuration files.

## Setup

ROX clients use [YAML](http://yaml.org) files for configuration.
To use a ROX Client, you need two configuration files.

In your home folder, you must create the `~/.rox/config.yml` configuration file.

```yml
# List of ROX Center servers you can submit test results to.
servers:
  rox.example.com:                        # A custom name for your ROX Center server.
                                          # You will use this in the client configuration file.
                                          # We recommend using the domain name where you deployed it.

    apiUrl: https://rox.example.com/api   # The URL of your ROX Center server's API.
                                          # This is the domain where you deployed it with /api.

    apiKeyId: 39fuc7x85lsoy9c0ek2d        # Your user credentials on this server.
    apiKeySecret: mwpqvvmagzoegxnqptxdaxkxonjmvrlctwcrfmowibqcpnsdqd

# If true, test results will be uploaded to ROX Center.
# Set to false to temporarily disable publishing.
# You can change this at runtime from the command line by setting the
# ROX_PUBLISH environment variable to 0 (false) or 1 (true).
publish: true
```

In the project directory where you run your tests, you must add the `rox.yml` client configuration file:

```yml
# Configuration specific to your project.
project:
  apiId: 154sic93pxs0   # The API key of your project in the ROX Center server.
  version: 1.2.3

# Where the client should store its temporary files.
# The client will work without it but it is required for some advanced features.
workspace: tmp/rox

# Client advanced features.
payload:
  
  # Saves a copy of the test payload sent to the ROX Center server for debugging.
  # The file will be saved in rspec/servers/<SERVER_NAME>/payload.json.
  save: false

  # If you track a large number of tests (more than a thousand), enabling this
  # will reduce the size of the test payloads sent to ROX Center server by caching
  # test information that doesn't change often such as the name.
  cache: false

  # Prints a copy of the test payload sent to the ROX Center server for debugging.
  # Temporarily enable at runtime by setting the ROX_PRINT_PAYLOAD environment variable to 1.
  print: false

# The name of the ROX Center server to upload test results to.
# This name must be one of the server names in the ~/.rox/config.yml file.
# You can change this at runtime from the command line by setting the
# ROX_SERVER environment variable.
server: rox.example.com
```

Finally, if using a standalone ROX client like [rox-client-rspec](https://github.com/lotaris/rox-client-rspec),
you must plug ROX into the testing framework.
This procedure is documented by each client.

## Contributing

* [Fork](https://help.github.com/articles/fork-a-repo)
* Create a topic branch - `git checkout -b my_feature`
* Push to your branch - `git push origin my_feature`
* Create a [pull request](http://help.github.com/pull-requests/) from your branch

Please add a [changelog](CHANGELOG.md) entry with your name for new features and bug fixes.

## License

The Ruby ROX Client is licensed under the [MIT License](http://opensource.org/licenses/MIT).
See [LICENSE.txt](LICENSE.txt) for the full license.
