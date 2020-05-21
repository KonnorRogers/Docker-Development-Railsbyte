# Docker-Development-Railsbyte

A way of setting up Docker in Development using a Rails generator thanks to railsbyte.

[https://railsbytes.com](https://railsbytes.com)

## Usage

```bash
rails app:template LOCATION="https://raw.githubusercontent.com/ParamagicDev/Docker-Development-Railsbyte/master/template.rb"
```

## Environment Variables

### Rails runtime

`RUBY_VERSION` Default: (Whatever you're RUBY_VERSION running Rails as)

`NODE_VERSION` Default: '12'

`RAILS_PORT` Default: '3000'

`WEBPACKER_PORT` Default: '3035'

### Postgres Variables

`DOCKER_POSTGRES_VERSION` Default: '12'

`DOCKER_POSTGRES_USER` Default: 'postgres' (You probably shouldnt change this)

`DOCKER_POSTGRES_PASSWORD` Default: 'EXAMPLE'

### Docker Variables

`DOCKER_USER_ID` Default: `Process.uid || 1000`

`DOCKER_GROUP_ID` Default: `Process.gid || 1000`

`DOCKER_USERNAME` Default: 'user'

`DOCKER_APP_DIR` Default: "home/#{DOCKER_USERNAME}/myapp"
