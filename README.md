# OES Jenkins Plus

Jenkins distribution for Opsbox.

## Build Jenkins

```bash
task jenkins:build
```

## Build Agent

```bash
docker-compose build jenkins-agent
```

## Test

```bash
 mkdir -p .data/jenkins
 sudo chown -R 1000:1000 .data/jenkins
 docker-compose up -d 
```