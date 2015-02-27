mayday-2.0
==========

[![Build Status](https://travis-ci.org/MayOneUS/mayday-2.0-backend.svg?branch=master)](https://travis-ci.org/MayOneUS/mayday-2.0-backend)
[![Code Climate](https://codeclimate.com/github/MayOneUS/mayday-2.0-backend/badges/gpa.svg)](https://codeclimate.com/github/MayOneUS/mayday-2.0-backend)

The API-driven next-generation MAYDAY site

Overview
--------

This is a [Rails 4.2](http://rubyonrails.org/) app. It uses a [PostgreSQL](http://www.postgresql.org/) database and a [Redis](http://redis.io/) server.

This is currently deployed on [Heroku](https://www.heroku.com/) in two environments:

- **Staging** https://mayone-staging.herokuapp.com/
- **Production** https://mayone-prod.herokuapp.com/

The `application.html.erb` template includes a `<meta>` tag instructing search engines to not index anything on the site.

Getting started
---------------

The app is a standard Rails app right now, so getting started should be straightforward for those with Rails experience.

### Docker

If you want to use [Docker](https://www.docker.com/) for local development, this repo comes with a `Dockerfile` and a [Docker Compose](https://docs.docker.com/compose/) configuration file (`docker-compose.yml`).

If you already have Docker and Docker Compose installed, starting this app is as easy as `docker-compose up`.

### RVM

*If you don't want to use Docker* for some reason, you can also just install ruby and all dependencies on your own:

1. Install [RVM](https://rvm.io/rvm/install).
1. Install Redis
1. Install Posgres and set up a user account.
1. Install gems w/ `bundle install`

Deployment & Hosting Environments
---------------------------------

### Staging

To hook up this app with Heroku's command line tool in your development environment, follow these instructions:

1. Make a Heroku account if you haven't already
1. Get someone to add you as a collaborator on the staging Heroku app
1. Install the Heroku toolbelt on your machine: https://toolbelt.herokuapp.com/
1. Once installed, run the `heroku login` command
1. `cd` into your clone of this repository, and run `heroku git:remote --app mayone-staging`

You can test if it works by running a command like `heroku logs`.

#### Common Staging Commands

Once you are connected to heroku, you can use the following to help testing

    heroku run rake db:seed        # seeds the db w/ legislators, states, zips
    heroku run rake db:dummy_data  # creates dummy campaign
    heroku run rake seed:purge     # Purge DB of all data
    heroku run rake seed:purge:api # Purge DB of API generated data

Note: only run rake db:seed and rake db:dummy_data after full purge

### Deploying to Production


Deployments to production are still manual for now. If you have already configured Heroku as specified in the development section above, you're halfway there:

1. Get someone to add you as a collaborator on the production Heroku app
1. `cd` into your clone of this repository and run `heroku git:remote -r prod --app mayone-prod`

You can now deploy to production the standard Heroku way. Example: `git push prod master`

You can also look at production logs with `heroku logs --app mayone-prod`.

## Continuous Integration

The site currently uses [Travis CI](https://travis-ci.org/) for Continuous Integration (CI). Whenever new code is pushed to the master branch (or included in a pull request), Travis will start a new build for that code.

Watch the builds here: https://travis-ci.org/MayOneUS/mayday-2.0-backend

**All successful builds of the master branch will be automatically deployed to the mayone-staging Herkou app.**

## Application monitoring

This app is configured to use [New Relic](http://newrelic.com/)'s application monitoring.

The easiest way to access the monitoring data is through the Heroku dashboard:

1. Go to https://dashboard.heroku.com/apps
1. Click on either the staging or production apps
1. Click on **New Relic APM**.

You will be automatically signed in to the New Relic dashboard.

## Contributing / Code Review Process

Key Goal: Ensure at least two parties have reviewed any code commited for "production."

## Process:
1. Fork/Branch off any new feature development
2. Regularly commit to your branch.
3. When done, create merge request into master. Your merge request should be conflict freeand all tests should be passing.
4. Assign another developer to review your merge request.
5. Merge request is reviewed and made on github.

License
-------

This project is open source under the [Apache License 2.0](LICENSE).

Note that while this license allows code reuse, it does not permit reuse of Mayday PAC branding or logos. If you reuse this project, you may need to remove Mayday PAC branding from the source code.