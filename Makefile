# Environmnent variables
DOCKER_COMPOSE_FILE=docker-compose.yml

# Install Docker
install-docker:
	@echo "Installing Docker..."
	@sudo apt-get update
	@sudo apt-get install -y docker.io
	@sudo systemctl start docker
	@sudo systemctl enable docker

# Start Wordpress in a container
start-wordpress:
	@echo "Starting Wordpress..."
	@sudo docker-compose ${DOCKER_COMPOSE_FILE} up -d

# Stop Wordpress
stop-wordpress:
	@echo "Stopping Wordpress..."
	@sudo docker compose ${DOCKER_COMPOSE_FILE} down

# Clean the containers and images
clean:
	@echo "Cleaning all containers and images..."
	@sudo docker-compose  ${DOCKER_COMPOSE_FILE} down --rmi all