#!/bin/bash

# Monitoring Stack Demo - Setup Script
# This script sets up the complete monitoring stack

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

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}$1${NC}"
}

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Create directory structure
print_header "📁 Creating directory structure..."

mkdir -p monitoring-stack-demo/{app,prometheus,grafana/{dashboards,provisioning/{dashboards,datasources}},loki}

print_status "Directory structure created"

# Check if we're in the right directory
if [ ! -f "docker-compose.yml" ]; then
    print_warning "docker-compose.yml not found. Make sure all files are in the current directory."
fi

# Pull all required Docker images
print_header "📦 Pulling Docker images..."

docker-compose pull

print_status "Docker images pulled successfully"

# Start the stack
print_header "🚀 Starting monitoring stack..."

docker-compose up -d

# Wait for services to be ready
print_header "⏳ Waiting for services to start..."

sleep 10

# Check service health
print_header "🔍 Checking service health..."

services=("app" "prometheus" "grafana" "loki")
for service in "${services[@]}"; do
    if docker-compose ps | grep -q "${service}.*Up"; then
        print_status "$service is running"
    else
        print_warning "$service might not be running properly"
    fi
done

# Generate some initial traffic
print_header "📊 Generating initial traffic..."

for i in {1..20}; do
    curl -s http://localhost:8080/ > /dev/null || true
    curl -s http://localhost:8080/health > /dev/null || true
    if [ $((i % 5)) -eq 0 ]; then
        curl -s http://localhost:8080/error > /dev/null || true
    fi
    sleep 0.5
done

print_status "Initial traffic generated"

# Display access information
print_header "🎯 Access Information"

echo ""
echo "Services are now available at:"
echo "├── Demo Application:  http://localhost:8080"
echo "├── Grafana:          http://localhost:3000 (admin/admin)"
echo "├── Prometheus:       http://localhost:9090"
echo "└── Loki:             http://localhost:3100"
echo ""

print_status "Setup complete! 🎉"

echo ""
echo "Next steps:"
echo "1. Open Grafana at http://localhost:3000"
echo "2. Login with admin/admin"
echo "3. Check out the pre-configured dashboards"
echo "4. Generate more traffic with: curl http://localhost:8080/"
echo ""

# Optional: Open browser (macOS/Linux)
read -p "Would you like to open Grafana in your browser? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if command -v xdg-open &> /dev/null; then
        xdg-open http://localhost:3000
    elif command -v open &> /dev/null; then
        open http://localhost:3000
    else
        print_warning "Could not open browser automatically. Please visit http://localhost:3000"
    fi
fi

print_status "Happy monitoring! 🚀"