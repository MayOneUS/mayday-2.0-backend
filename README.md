mayone-2.0
==========

The API-driven next-generation MADAY site

Overview
--------

This is currently an out-of-the-box [Rails 4.2](http://rubyonrails.org/) app. It uses a [PostgreSQL](http://www.postgresql.org/) database.

It is currently deployed on [Heroku](https://www.heroku.com/) in two environments:

- **Staging** https://mayone-staging.herokuapp.com/
- **Production** https://mayone-prod.herokuapp.com/

The `application.html.erb` template includes a `<meta>` tag instructing search engines to not index anything on the site.

Getting started
---------------

The app is a standard Rails app right now, so getting started should be straightforward for those with Rails experience.

### Docker

If you want to use [Docker](https://www.docker.com/) for local development, this repo comes with a `Dockerfile` and a [Fig](http://www.fig.sh/index.html) configuration file (`fig.yml`).

If you already have Docker and Fig installed, starting this app is as easy as `fig up`.

### Heroku

To hook up this app with Heroku's command line tool in your development environment, follow these instructions:

1. Make a Heroku account if you haven't already
1. Get someone to add you as a collaborator on the staging Heroku app
1. Install the Heroku toolbelt on your machine: https://toolbelt.herokuapp.com/
1. Once installed, run the `heroku login` command
1. `cd` into your clone of this repository, and run `heroku git:remote --app mayone-staging`

You can test if it works by running a command like `heroku logs`.

Continuous Integration
----------------------

The site currently uses [CircleCI](https://circleci.com/) for Continuous Integration (CI). Whenever new code is pushed to the repository, CircleCI will start a new build for that code.

CircleCI uses GitHub for authentication, so if you have access to this repo you should have access to the CircleCI builds.

Watch the builds here: https://circleci.com/gh/atbaker/mayone-2.0

CircleCI will automatically deploy all successful builds to the mayone-staging Herkou app.

Deploying to production
-----------------------

Deployments to production are still manual for now. If you have already configured Heroku as specified in the development section above, you're halfway there:

1. Get someone to add you as a collaborator on the production Heroku app
1. `cd` into your clone of this repository and run `heroku git:remote -r prod --app mayone-prod`

You can now deploy to production the standard Heroku way. Example: `git push prod master`

You can also look at production logs with `heroku logs --app mayone-prod`.

Application monitoring
----------------------

This app is configured to use [New Relic](http://newrelic.com/)'s application monitoring.

The easiest way to access the monitoring data is through the Heroku dashboard:

1. Go to https://dashboard.heroku.com/apps
1. Click on either the staging or production apps
1. Click on **New Relic APM**.

You will be automatically signed in to the New Relic dashboard.
