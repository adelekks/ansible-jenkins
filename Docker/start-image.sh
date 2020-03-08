#!/usr/bin/env bash
docker-compose build && docker-compose down && docker-compose up -d
sleep 20
echo "========================================================================================
Jekins Password
`docker exec docker_jenkins_1 cat /var/lib/jenkins/secrets/initialAdminPassword`
Jenkins URL: localhost:8080
You need to install this Plugin before creating Folders hashicorp-vault and cloudbees
And restart Jenkins
Now login you into the jenkins container
You can logout from the jenkins container with eixt
========================================================================================"
docker exec -it docker_jenkins_1 /bin/bash
