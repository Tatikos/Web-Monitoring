#!/bin/bash

# Monitoring Stack Demo - Setup Script
# Modified version that doesn't create additional directories

set -e

echo "🚀 Setting up Monitoring Stack Demo..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}$1${NC}"
}

# Check prerequisites
print_header "🔍 Checking prerequisites..."

if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

print_status "All prerequisites are installed"

# Pull Docker images
print_header "📦 Pulling Docker images..."
docker-compose pull
print_status "Docker images pulled successfully"

# Start the stack
print_header "🚀 Starting monitoring stack..."
docker-compose up -d

# Wait for services
print_header "⏳ Waiting for services to initialize..."
sleep 10

# Verify services
print_header "🔍 Verifying services..."
services=("app" "prometheus" "grafana" "loki")
all_ok=true

for service in "${services[@]}"; do
    if docker-compose ps | grep -q "${service}.*Up"; then
        print_status "$service is running"
    else
        print_error "$service failed to start"
        all_ok=false
    fi
done

if [ "$all_ok" = false ]; then
    print_error "Some services failed to start. Check logs with: docker-compose logs"
    exit 1
fi

# Generate initial traffic
print_header "📊 Generating initial traffic..."
for i in {1..10}; do
    curl -s http://localhost:8080/ > /dev/null
    curl -s http://localhost:8080/health > /dev/null
    sleep 0.2
done
print_status "Initial traffic generated"

# Display access info
print_header "🎯 Access Information"
echo ""
echo "Services are now available at:"
echo "├── Demo Application:  http://localhost:8080"
echo "├── Grafana:          http://localhost:3000 (admin/admin)"
echo "├── Prometheus:       http://localhost:9090"
echo "└── Loki:             http://localhost:3100"
echo ""
print_status "Setup complete! 🎉"