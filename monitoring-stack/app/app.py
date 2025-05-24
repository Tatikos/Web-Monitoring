from flask import Flask, jsonify, request, make_response
from prometheus_client import Counter, Histogram, Gauge, generate_latest, CONTENT_TYPE_LATEST
import time
import random
import logging
import json
from datetime import datetime

# Configure structured logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s %(levelname)s %(message)s',
    handlers=[
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

app = Flask(__name__)

# Prometheus metrics
REQUEST_COUNT = Counter(
    'app_requests_total', 
    'Total HTTP requests', 
    ['method', 'endpoint', 'status']
)

REQUEST_DURATION = Histogram(
    'app_request_duration_seconds', 
    'HTTP request duration in seconds',
    ['method', 'endpoint']
)

ERROR_COUNT = Counter(
    'app_errors_total', 
    'Total application errors',
    ['error_type']
)

ACTIVE_USERS = Gauge(
    'app_active_users', 
    'Number of active users'
)

# Simulate some active users
ACTIVE_USERS.set(random.randint(10, 100))

def log_request(endpoint, method, status_code, duration=None, error=None):
    """Structured logging for requests"""
    log_data = {
        'timestamp': datetime.utcnow().isoformat(),
        'endpoint': endpoint,
        'method': method,
        'status_code': status_code,
        'user_agent': request.headers.get('User-Agent', ''),
        'ip_address': request.remote_addr,
    }
    
    if duration:
        log_data['duration_seconds'] = duration
    
    if error:
        log_data['error'] = error
    
    if status_code >= 400:
        logger.error(json.dumps(log_data))
    else:
        logger.info(json.dumps(log_data))

@app.before_request
def before_request():
    request.start_time = time.time()

@app.after_request
def after_request(response):
    duration = time.time() - request.start_time
    
    # Update Prometheus metrics
    REQUEST_COUNT.labels(
        method=request.method,
        endpoint=request.endpoint or 'unknown',
        status=response.status_code
    ).inc()
    
    REQUEST_DURATION.labels(
        method=request.method,
        endpoint=request.endpoint or 'unknown'
    ).observe(duration)
    
    # Log the request
    log_request(
        endpoint=request.endpoint or 'unknown',
        method=request.method,
        status_code=response.status_code,
        duration=duration
    )
    
    return response

@app.route('/')
def home():
    """Main endpoint"""
    # Simulate some processing time
    time.sleep(random.uniform(0.01, 0.1))
    
    # Randomly update active users
    if random.random() < 0.1:  # 10% chance
        ACTIVE_USERS.set(random.randint(10, 100))
    
    return jsonify({
        'message': 'Hello from the monitoring demo app!',
        'timestamp': datetime.utcnow().isoformat(),
        'version': '1.0.0'
    })

@app.route('/health')
def health():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.utcnow().isoformat(),
        'checks': {
            'database': 'ok',
            'cache': 'ok',
            'external_service': 'ok'
        }
    })

@app.route('/slow')
def slow():
    """Simulate a slow endpoint"""
    delay = random.uniform(1, 3)
    time.sleep(delay)
    
    return jsonify({
        'message': f'This took {delay:.2f} seconds',
        'timestamp': datetime.utcnow().isoformat()
    })

@app.route('/error')
def error():
    """Simulate an error"""
    error_types = ['database_error', 'network_error', 'validation_error', 'timeout_error']
    error_type = random.choice(error_types)
    
    ERROR_COUNT.labels(error_type=error_type).inc()
    
    log_request(
        endpoint='error',
        method='GET',
        status_code=500,
        error=f'Simulated {error_type}'
    )
    
    return jsonify({
        'error': f'Simulated {error_type}',
        'timestamp': datetime.utcnow().isoformat()
    }), 500

@app.route('/api/users')
def users():
    """Simulate user data endpoint"""
    users = []
    for i in range(random.randint(1, 10)):
        users.append({
            'id': i + 1,
            'name': f'User {i + 1}',
            'active': random.choice([True, False]),
            'last_seen': datetime.utcnow().isoformat()
        })
    
    return jsonify({
        'users': users,
        'total': len(users),
        'timestamp': datetime.utcnow().isoformat()
    })

@app.route('/api/stats')
def stats():
    """Application statistics"""
    return jsonify({
        'uptime_seconds': time.time() - app.start_time,
        'active_users': random.randint(10, 100),
        'requests_per_minute': random.randint(50, 200),
        'error_rate': round(random.uniform(0, 5), 2),
        'avg_response_time_ms': round(random.uniform(50, 200), 2),
        'timestamp': datetime.utcnow().isoformat()
    })

@app.route('/metrics')
def metrics():
    """Prometheus metrics endpoint"""
    return make_response(generate_latest(), 200, {'Content-Type': CONTENT_TYPE_LATEST})

@app.errorhandler(404)
def not_found(error):
    ERROR_COUNT.labels(error_type='not_found').inc()
    return jsonify({'error': 'Not found'}), 404

@app.errorhandler(500)
def internal_error(error):
    ERROR_COUNT.labels(error_type='internal_server_error').inc()
    return jsonify({'error': 'Internal server error'}), 500

if __name__ == '__main__':
    app.start_time = time.time()
    
    logger.info(json.dumps({
        'timestamp': datetime.utcnow().isoformat(),
        'message': 'Starting monitoring demo application',
        'version': '1.0.0'
    }))
    
    app.run(host='0.0.0.0', port=8080, debug=False)