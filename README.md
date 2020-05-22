# Docker-Development-Railsbyte

A way of setting up Docker in Development using a Rails generator thanks to railsbyte.

[https://railsbytes.com](https://railsbytes.com)

## Usage

```bash
rails app:template LOCATION="https://raw.githubusercontent.com/ParamagicDev/Docker-Development-Railsbyte/master/template.rb"
```

## Notes

Please note, we will not hard code your POSTGRES_PASSWORD into your
`docker-compose.yml` file. Instead, you can set your
`DOCKER_POSTGRES_PASSWORD` in your shell and `docker-compose.yml` will
read its value when building the Postgres database.

Alternatively, you can answer the prompt on the command line and we will
set the `DOCKER_POSTGRES_PASSWORD` environment variable for you.

## Environment Variables

### Rails runtime

`RUBY_VERSION` Default: (Whatever you're RUBY_VERSION running Rails as)

`NODE_VERSION` Default: '12'

`RAILS_PORT` Default: '3000'

`WEBPACKER_PORT` Default: '3035'

### Postgres Variables

`DOCKER_POSTGRES_VERSION` Default: '12'

`DOCKER_POSTGRES_USER` Default: 'postgres' (You probably shouldnt change this)

`DOCKER_POSTGRES_PASSWORD` No default given, the user must set this
themselves.

### Docker Variables

`DOCKER_USER_ID` Default: `Process.uid || 1000`

`DOCKER_GROUP_ID` Default: `Process.gid || 1000`

`DOCKER_USERNAME` Default: 'user'

`DOCKER_APP_DIR` Default: "home/#{DOCKER_USERNAME}/myapp"

## Updating Default Files

Files can quickly become out of date. I set up a Rake task to remain in
line with defaults from the `templates/erb/*` files.

Run:

```bash
rake update_default_templates
```

To update the files in the `templates/default/` directory.
