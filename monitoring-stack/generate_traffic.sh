#!/bin/bash

# Traffic Generator for Monitoring Stack Demo
# This script generates various types of traffic to demonstrate monitoring

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

APP_URL="http://localhost:8080"

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if the app is running
check_app() {
    if ! curl -s "$APP_URL/health" > /dev/null; then
        print_error "Application is not responding at $APP_URL"
        print_info "Make sure to run 'docker-compose up -d' first"
        exit 1
    fi
    print_info "Application is running at $APP_URL"
}

# Generate normal traffic
normal_traffic() {
    print_info "Generating normal traffic..."

    for i in {1..50}; do
        curl -s "$APP_URL/" > /dev/null
        curl -s "$APP_URL/health" > /dev/null
        curl -s "$APP_URL/api/users" > /dev/null
        sleep 0.2
    done

    print_info "Normal traffic completed."
}

# Generate error traffic
error_traffic() {
    print_info "Generating error traffic..."

    for i in {1..20}; do
        curl -s -o /dev/null -w "%{http_code}\n" "$APP_URL/api/nonexistent" || true
        sleep 0.1
    done

    print_info "Error traffic completed."
}

# Generate spike in load
spike_traffic() {
    print_warning "Generating traffic spike..."

    for i in {1..100}; do
        curl -s "$APP_URL/" > /dev/null &
    done

    wait
    print_info "Traffic spike completed."
}

# Main
check_app
normal_traffic
error_traffic
spike_traffic

print_info "Traffic generation complete. Check your monitoring dashboards!"
