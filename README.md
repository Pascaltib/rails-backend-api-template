# Audemic Backend

This is a Ruby on Rails API application. This application uses Rails version 7.0.4.3 and Ruby version 3.1.2.

## PostgreSQL

The project is using PostgreSQL relational database along with ActiveRecord as
the ORM.

Here's how to install and start PostgreSQL via homebrew on mac and linux

```shell
brew install postgresql
brew services start postgresql
```

### Redis

The project is using sidekiq for scheduled jobs, which depends on Redis.

Here's how to install and start it on mac:

```shell
brew install redis
brew services start redis
```

And this is for Ubuntu:

```shell
sudo apt-get install redis-server
```

## Installation

1. Clone the repository:

sh git clone git@github.com:Audemic/audemic-backend.git

2. Navigate to the repository directory:

sh cd audemic-backend

3. Install Ruby dependencies:

sh bundle install


4. Set up the database:

sh rails db:create db:migrate

## Running the Application

You can start the Rails server with the following command:

sh rails s

## Running Tests

This application uses RSpec for testing. Run the tests with:

sh rspec

## Setup Git Hooks

After cloning the repository, you'll need to set up the Git hooks:

1. Copy the hooks from the repo into the .git/hooks directory:

sh cp git-hooks/* .git/hooks/

2. Make sure the hooks are executable:

sh chmod +x .git/hooks/*

## JWT Devise guide
https://dakotaleemartinez.com/tutorials/devise-jwt-api-only-mode-for-authentication/
