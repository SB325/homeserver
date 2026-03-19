#stop and remove all containers
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
yes | docker rmi $(docker image ls -a -q) 

#remove old images (-f prevents prompt for confirmation)
yes | docker image prune -f 
yes | docker builder prune -f
yes | docker container prune -f
yes | docker image rm $(docker image ls -a -q) -f
yes | docker system prune -a
