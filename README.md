# DataProducer

A Data Producer Engine, publishes data

## Contents

- [Installation](#installation) -:- [Gemfile](#in-a-gemfile) | [CirlceCI](#in-circle-ci) | [Locally](#locally)
- [Usage](#usage) -:- [Prerequisites](#prerequisites) | [Configuration](#configuration) | [Monitoring Data](#monitoring-data) | [Command-Line](#command-line)
- [Contributing](#contributing) -:- [Quickstart](#quickstart) | [Guidelines](#guidelines) | [STRTA](#scripts-to-rule-them-all) | [KISS](#kiss)
- External Links
  - [Architectural Diagram](https://miro.com/app/board/o9J_l3FM0qA=/?moveToWidget=3458764514802313756&cot=14)

## Installation

In order to install this engine in a project the project of choice, first create a [PAT](https://docs.github.com/en/github/authenticating-to-github/keeping-your-account-and-data-secure/creating-a-personal-access-token) with
`repo` access. This will ensure the environment has the ability to install this privately hosted gem from Github. This will have to be done
to use this gem in any environment except locally (see environment specific installs below).

```
bundle config --local GITHUB__COM [myoauthtoken]:x-oauth-basic

# if also using dip/docker
dip bundle config --local GITHUB__COM [myoauthtoken]:x-oauth-basic
```

### In A Gemfile

```ruby
group :test, :development do
  gem "data_producer", git: "https://github.com/rubyDoomsday/data_producer.git", tag: "v0.1.1"
end
```

Then update your bundle:

```
bundle install

# for dip/docker
dip bundle install
```

### Locally

When installing gems from Github private repos, Bundler actually pulls down the code and builds the gem for you. If you want to install the
gem locally then you have to do the same. The following commands should do it:

    git clone https://github.com/rubyDoomsday/data_producer.git && \
    cd data_producer && \
    gem install `gem build data_producer | grep -o '[^:]*\.gem'`

## Usage

### Prerequisites

This project uses Kinesis data streams as the messaging backbone. As such this will require that [AWS Security
Credentials](http://docs.aws.amazon.com/general/latest/gr/aws-security-credentials.html) with access to Kinesis streams be available on the
system. At this time **only live Kinesis streams are supported** due to a limitation of the AWS MultiLangDaemon. With that in mind we do not
share a single set of production credentials to avoid accidental linkage to the live stream.

By default this uses the [DefaultAWSCredentialsProviderChain][defaultawscredentialsproviderchain]
so it is important to make sure that credentials available through one of the mechanisms in that
provider chain. There are several ways to do this the easiest being to provide a `~/.aws/credentials` file. For example:

```
  echo "aws_access_key_id=myAccessKey" >> ~/.aws/credentials
  echo "aws_secret_access_key=mySecretKey" >> ~/.aws/credentials
```

For questions regarding [Amazon Kinesis Service][amazon-kinesis] and the client libraries please check the
[official documentation][amazon-kinesis-docs] as well as the [Amazon Kinesis Forums][kinesis-forum].

### Configuration

Once the engine is installed using the installation method of choice above, a few configuration details
are required to inform the engine of some project specifics. It is recommended to keep configuration details out of the application code and
access the environment specific details through `Rails.configuration` or similar methods. Details here are for example purposes only.

```ruby
# config/initializers/data_producer.rb

DataProducer.configure do |c|
  c.client_id = "My Awesome Project"
  c.aws_region = "us-east-2"
  c.aws_access_key_id = "MY ACCESS KEY"
  c.aws_secret_access_key = "MY SECRET KEY"
  c.topic = "interesting-topic-name"
end
```

| Option                  | Required | Type    | Description                       | Default                  |
| ----------------------- | -------- | ------- | --------------------------------- | ------------------------ |
| `aws_region`            | yes      | string  | The AWS region                    | us-east-2                |
| `aws_access_key_id`     | yes      | string  | The AWS ACCESS KEY                | DATA_PRODUCER_ACCESS_KEY |
| `aws_secret_access_key` | yes      | string  | The AWS SECRET KEY                | DATA_PRODUCER_SECRET_KEY |
| `kinesis_host`          | no       | url     | The Kinesis url                   | null                     |
| `logger`                | no       | logger  | The application logger instance   | Rails.logger             |
| `client_id`             | no       | string  | The name of the project           | Application Name         |
| `deliver`               | no       | boolean | Enables delivery or mock delivery | false                    |
| `keep_alive`            | no       | boolean | Enable/Disable keep alive message | false                    |
| `topic`                 | no       | string  | The AWS stream name               | data                     |

Once configured you may start the engine at any point but it is recommended to do so from an initializer. This will connect the project to
the message bus. If the bus is not available or misconfigured an error message will be raised. Starting the engine prior to
configuration will use the default config which you may not want. However, this does allow performing checks before making any attempts to
publish out to the message bus.

```ruby
# config/initializers/data_producer.rb

# ...

DataProducer.start
```

If there is a need to disable the engine from monitoring data, publishing a keep alive etc. run:

```
DataProducer.stop
```

### Monitoring Data

The Data Producer Engine monitors models for `create`, `update`, and/or `destroy` events on models within the application. You may choose to
monitor all or some of these events as well as all or some of the models depending on your needs. To observe a model add the following line
somewhere at the top of the model class:

Monitoring a single model

```ruby
# app/models/user.rb

class User < ApplicationRecord
  # ...
  monitor :create, :update, :destroy
  # ...
end
```

Monitoring many models (through inheritance)

```ruby
# app/models/data_producer_base.rb
class DataProducerBase < ApplicationRecord
  monitor :create, :update, :destroy
end

# app/models/user.rb
class User < DataProducerBase
  # ...
end
```

### Command-Line

There is a command line utility included as part of this library to better facilitate testing. See `bin/publish` for details or run:

```
bundle exec bin/publish --help
```

## Contributing

### Quickstart

Clone the repo to get the code

    git clone https://github.com/rubyDoomsday/data_producer.git && cd data_producer

Setup git hooks to keep the code clean

    ln -s ../../.git_hooks/pre-commit-hooks $(git rev-parse --git-dir)/hooks/pre-commit

Code!

### Scripts-to-Rule-Them-All

This project was built under the STRTA principles to setup the local development environment run the following commands to bootstrap your
environment, setup your database and run the test suite with a Simplecov report.

```
  script/bootstrap
  script/setup
  COVER=true script/test
```

This project uses [yard](https://github.com/lsegal/yard) for code documentation. Since this is a gem library used by many FTF projects/teams
it is recommended that all public interfaces be documented. See [yard tags](https://www.rubydoc.info/gems/yard/file/docs/Tags.md) for more
details. To see view docs run the following script command.

```
  script/docs
```

### Guidelines

This project uses a modified [Github Flow](https://githubflow.github.io/). The modifications are as follows:

- Deployment (Step #6): There is no deployment pipeline for gems/engines

This project also uses [Jira Development Tracking](https://support.atlassian.com/jira-software-cloud/docs/view-development-information-for-an-issue/) hooks to link branches to Jira
tickets. The branch naming convention is as follows `[LABEL]/[PROJECT CODE]-[TICKET #]-[optional/addt'l descriptors]`.

The example below uses [github cli](https://cli.github.com/) and [git](https://git-scm.com/about) to illustrate a typical workflow and
branch naming:

```
  # @Contribute
  data_producer git:(main)> git checkout -b feature/DATA-1234-new-thing
  data_producer git:(feature/DATA-1234-new-thing)> # make code changes
  data_producer git:(feature/DATA-1234-new-thing)> git add . && git commit -m "what/why/links/etc"
  data_producer git:(feature/DATA-1234-new-thing)> git push -u origin HEAD
  data_producer git:(feature/DATA-1234-new-thing)> gh pr create -f -B main -a myUserName

  # @Review
  # address feedback, harden testing, QA in project as needed, etc.
  # Note: To install the updates to a project without mering to main simply point
  # the gemfile to the branch that contains the changes:
  #  gem "data_producer", ftf: "data_producer.git", branch: "feature/DATA-1234-new-thing"

  # @Deploy
  data_producer git:(feature/DATA-1234-new-thing)> gh pr merge

  # @Rinse and Repeat
  data_producer git:(main)> git checkout main
```

#### KISS

_Keep It Simple Simon_

- Keep pull request's review footprint small (500+/- lines).
- Only merge pull requests that you own unless given explicit permission.
- Squash commits on merge **with a descriptive title and message**.
- Assume best intentions when reading, and be constructive when writing PR comments.
- Prune your branches after merge. Only `main` should be persistent.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

[amazon-kinesis]: http://aws.amazon.com/kinesis
[amazon-kinesis-docs]: http://aws.amazon.com/documentation/kinesis/
[kinesis-forum]: http://developer.amazonwebservices.com/connect/forum.jspa?forumID=169
[defaultawscredentialsproviderchain]: http://docs.aws.amazon.com/AWSJavaSDK/latest/javadoc/com/amazonaws/auth/DefaultAWSCredentialsProviderChain.html
