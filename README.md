# Overview

Scenario: need to update docker container which running on a vm when code changed.

Provision ec2 instanse:

```shell
terraform init
terraform plan
terraform apply
```

Login on the server and launch container via docker-compose.

Add host ip, private ssh key, and dockerhub access token to github secrets.

```shell
❯ http http://54.93.102.177:8080/info
HTTP/1.1 200 OK
content-length: 92
content-type: application/json
date: Fri, 24 Dec 2021 19:28:55 GMT
server: uvicorn

{
    "commit": "e2a7542e87ed2d1bcd750e640e6e2336865e6771",
    "pipeline": "1620024445",
    "tag": "master"
}
```
