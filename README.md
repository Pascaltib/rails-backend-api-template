# Audemic Backend

This is a Ruby on Rails API application. This application uses Rails version 7.0.4.3 and Ruby version 3.1.2.

# Features
- Rubocop (configured for rails and rspec)
- CI/CD flows with GitHub actions including:
  - Listing tests with rubocop
  - Brakeman security scanner which detects common security risks in code
  - Bundler audit to check for security vulnerabilities in gems
  - Running rspec tests
- Rate limiting (DDOS) protection using rack-attack
- Devise and JWT:
  - You can change JWT expiration time in config/initializers/devise.rb
  - The devise jwt configuration uses the https://github.com/waiting-for-dev/devise-jwt#jtimatcher revocation strategy.
- Two authentication flows
  - Email or phone number signup and login
  - OTP verification via Twilio API

 If you are creating a new github repo, I would recommend adding dependabot to the repository. In GitHub go to security -> dependabot -> configure -> manage repository vulnerability settings. Enable dependency graph, dependabot alerts, and dependabot security updates. If a gem version has a security alert, dependabot will automatically create a pull request with the version fix.

#Installation

## PostgreSQL

The project is using PostgreSQL relational database along with ActiveRecord as
the ORM.

Here's how to install and start PostgreSQL via homebrew on mac and linux

```
brew install postgresql
brew services start postgresql
```

### Redis

The project is using sidekiq for scheduled jobs, which depends on Redis.

Here's how to install and start it on mac:

```
brew install redis
brew services start redis
```

And this is for Ubuntu:

```
sudo apt-get install redis-server
```

If you want to flush your redis store, run:

```
redis-cli flushall
```

## Installation

1. Clone the repository:

  ```
  git clone git@github.com:Audemic/audemic-backend.git
  ```

2. Navigate to the repository directory:
  ```
  cd audemic-backend
  ```

3. Install Ruby dependencies:

  ```
  bundle install
  ```

4. Set up the database:
```
rails db:create db:migrate
```

## Running the Application

You can start the Rails server with the following command:

```
rails s
```

## Running Tests

This application uses RSpec for testing. Run the tests with:
```
rspec
```

## Setup Git Hooks

After cloning the repository, you'll need to set up the Git hooks:

1. Navigate to your project's directory and then into the .git/hooks directory:
```
cd ./.git/hooks
```

2. Create a new file named pre-commit (without any extension):
```
touch pre-commit
```

3. Open this file in your favorite text editor, and add the following script:

```
#!/bin/sh
git diff --cached --name-only | xargs -I {} rubocop --force-exclusion {}
```

4. Make sure the hooks are executable:
```
chmod +x pre-commit
```

## JWT Devise guide
https://dakotaleemartinez.com/tutorials/devise-jwt-api-only-mode-for-authentication/
