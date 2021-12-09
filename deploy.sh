#!/bin/bash
# echo "Stopping All Containers..."
# docker stop \$(docker ps -a --format "{{.ID}}") || exit 0
# echo "Removing All Containers..."
# docker rm \$(docker ps -a --format "{{.ID}}") || exit 0
# echo "Removing all Images..."
# docker rmi \$(docker images --format "{{.ID}}") || exit 0

# Store list of running containerIDs in a variable 
containers=$(docker ps -q)
echo ${containers}

# Stop the running containers
docker stop ${containers}

# Remove the containers
docker rm ${containers}

# Remove all images
docker rmi $(docker images -q)

#Create network
docker network create trio-task-network

#Create volume
docker volume create trio-db-volume

#Building images
docker build -t trio-db db
docker build -t trio-flask-app flask-app

#run db container
docker run -d \
    --network trio-task-network \
    --volume trio-db-volume:/var/lib/mysql \
    --name mysql \
    trio-db

#run flask app
docker run -d \
    --network trio-task-network \
    --name flask-app \
    trio-flask-app

#run nginx container
docker run -d \
    --network trio-task-network \
    --mount type=bind,source=$(pwd)/nginx/nginx.conf,target=/etc/nginx/nginx.conf \
    -p 80:80 \
    --name nginx \
    nginx:alpine

