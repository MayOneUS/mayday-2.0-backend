mayday-2.0
==========

[![Build Status](https://travis-ci.org/MayOneUS/mayday-2.0-backend.svg?branch=master)](https://travis-ci.org/MayOneUS/mayday-2.0-backend)
[![Code Climate](https://codeclimate.com/github/MayOneUS/mayday-2.0-backend/badges/gpa.svg)](https://codeclimate.com/github/MayOneUS/mayday-2.0-backend)

The API-driven next-generation MAYDAY site

Overview
--------

This is a [Rails 4.2](http://rubyonrails.org/) app. It uses a [PostgreSQL](http://www.postgresql.org/) database and a [Redis](http://redis.io/) server.

This is currently deployed on [Heroku](https://www.heroku.com/) in two environments:

- **Staging** https://services-staging.mayday.us/
- **Step Two Staging:** https://services-step-two.mayday.us/
- **Production** https://services.mayday.us

The `application.html.erb` template includes a `<meta>` tag instructing search engines to not index anything on the site.

Getting started
---------------

The app is a standard Rails app right now, so getting started should be straightforward for those with Rails experience.

### Environment variables

After you clone the repository, copy the `.env.example` file to `.env`, and supply real values for any environment variables you will need for your development work. Another MAYDAY Tech Team member can help you with this.

### Docker

If you want to use [Docker](https://www.docker.com/) for local development, this repo comes with a `Dockerfile` and a [Docker Compose](https://docs.docker.com/compose/) configuration file (`docker-compose.yml`).

If you already have Docker and Docker Compose installed, starting this app is as easy as `docker-compose up`.

After you've created the Docker containers, you can apply the migrations to the database with `docker-compose run web rake db:migrate`.

### RVM

*If you don't want to use Docker* for some reason, you can also just install ruby and all dependencies on your own:

1. Install [RVM](https://rvm.io/rvm/install).
1. Install Redis
1. Install Posgres and set up a user account.
1. Install gems w/ `bundle install`

You will also need to start a local PostgreSQL database and a Redis instance.

Finally, apply the database migrations with `rake db:migrate`.

### Sidekiq worker

This app uses [sidekiq](https://github.com/mperham/sidekiq) to do background processing for a few tasks.

By default, the app expects a sidekiq worker process to be available. You can start this process locally by running `bundle exec sidekiq -c 5`.

If you don't want to send jobs to sidekiq, you can set the `SIDEKIQ_TESTING` environment variable to `'inline'` or `'fake'`.


Deployment & Hosting Environments
---------------------------------

### Staging

To hook up this app with Heroku's command line tool in your development environment, follow these instructions:

1. Make a Heroku account if you haven't already
1. Get someone to add you as a collaborator on the staging Heroku app
1. Install the Heroku toolbelt on your machine: https://toolbelt.herokuapp.com/
1. Once installed, run the `heroku login` command
1. `cd` into your clone of this repository, and run `heroku git:remote -r staging --app mayone-staging`

You can test if it works by running a command like `heroku logs`.

You can now deploy to staging the standard Heroku way. Example: `git push mayone-staging master`

### Common Staging Commands

Once you are connected to heroku, you can use the following to help testing

    heroku run rake db:seed              # seeds the db w/ legislators, states, zips
    heroku run rake db:seed:dummy_data   # creates dummy campaign
    heroku run rake db:purge             # Purge DB of all data
    heroku run rake db:purge:api         # Purge DB of API generated data
    heroku run rake db:purge:dummy_data  # Purge DB of dummy seed data

Note: only run `rake db:seed` after full purge

### Deploying to Production

Deployments to production are still manual for now. If you have already configured Heroku as specified in the development section above, you're halfway there:

1. Get someone to add you as a collaborator on the production Heroku app
1. `cd` into your clone of this repository and run `heroku git:remote -r prod --app mayone-prod`

You can now deploy to production the standard Heroku way. Example: `git push prod master`

You can also look at production logs with `heroku logs --app mayone-prod`.

## Continuous Integration

The site currently uses [Travis CI](https://travis-ci.org/) for Continuous Integration (CI). Whenever new code is pushed to the master branch (or included in a pull request), Travis will start a new build for that code.

Watch the builds here: https://travis-ci.org/MayOneUS/mayday-2.0-backend

**All successful builds of the `master` branch will be automatically deployed to the staging Herkou app.** All successful builds of the `m2` branch will be automatically deployed to the step two staging app.

## Application monitoring

### New Relic

This app is configured to use [New Relic](http://newrelic.com/)'s application monitoring.

The easiest way to access the monitoring data is through the Heroku dashboard:

1. Go to https://dashboard.heroku.com/apps
1. Click on either the staging or production apps
1. Click on **New Relic APM**.

You will be automatically signed in to the New Relic dashboard.

### Sidekiq

We use a different approach to monitor sidekiq (taken from the [sidekiq wiki](https://github.com/mperham/sidekiq/wiki/Monitoring)). First, we expose two URLs which give basic information about the queue status:

- `/queue-status` will return `OK` if the queue size is less than 100, or `UHOH` if it's above 100
- `/queue-latency` will return `OK` if the queue latency is less then 30 seconds, or `UHOH` if it's above 30 seconds

We monitor these URLs using [Pingdom](https://www.pingdom.com/) and alert our Slack #engineering channel when there's an issue.

We also run the sidekiq dashboard UI on our Heroku servers. You can access it by going to `/sidekiq`. Ask another MAYDAY Tech Team member for the password to this dashboard on our staging and production servers.

### Troubleshooting

Sometimes the production site has hiccups. Here are tips on how to solve some common ones:

#### Maxing out Postgres connections

About every other month, a New Relic alert gets triggered because our Heroku dynos can't connect to the Postgres database. This is most likely because the Postgres database has run out connections - our current plan only allows for 20.

Until we can figure out something better, solve this by running killing the current connections. Run `heroku pg:killall -amayone-prod`. That will terminate all connections to the Postgres database. You should then run `heroku restart --app mayone-prod` **immediately** so that all worker and web dynos reestablish their connections to the database.  We haven't prioritized resolving this as it doesn't seem related to traffic congestion.

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
