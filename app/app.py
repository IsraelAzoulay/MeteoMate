# Importing necessary libraries and modules
from flask import Flask, render_template, request, redirect
import requests
import os
import sys 
from pymongo import MongoClient
import logging
from dotenv import load_dotenv
import certifi
from functools import lru_cache

# Load environment variables from the .env file
load_dotenv()

# Configure logging settings
# Define the base directory, static folder path, and log directory path
basedir = os.path.abspath(os.path.dirname(__file__))
static_folder_path = os.path.join(basedir, '..', 'static')
log_dir_path = os.path.join(basedir, '..', 'logs')
# Set up the logging configuration
if os.getenv('ENVIRONMENT') == 'PRODUCTION':
    logging.basicConfig(level=logging.INFO, format='%(asctime)s:%(levelname)s:%(message)s')
else:
    logging.basicConfig(filename=os.path.join(log_dir_path, 'app.log'), level=logging.INFO, format='%(asctime)s:%(levelname)s:%(message)s')
os.makedirs(log_dir_path, exist_ok=True)

# Initialize the Flask application
app = Flask(__name__, template_folder='templates', static_folder=static_folder_path)
app.debug = False
app.config['PROPAGATE_EXCEPTIONS'] = True

@app.before_request
def before_request():
    # Redirect HTTP requests to HTTPS in production environment
    # if os.getenv('ENVIRONMENT') == 'PRODUCTION' and not request.is_secure:
        # url = request.url.replace('http://', 'https://', 1)
        # code = 301
        # return redirect(url, code=code)

    # Existing logging functionality
    logging.info(f"Before Request: {request.endpoint}")

@app.after_request
def after_request(response):
    logging.info(f"After Request: {request.endpoint} responded with {response.status}")
    return response

@app.route('/health')
def health():
    return 'OK', 200

def create_mongo_client():
    """
    Create and return a MongoDB client.
    
    Returns:
        db: MongoDB database instance
    """
    connection_string = os.getenv('MONGODB_URI')
    client = MongoClient(connection_string, tlsCAFile=certifi.where())  
    db = client["mydatabase"]
    return db

@lru_cache(maxsize=32)  # Cache up to 32 unique city requests
def fetch_weather_data(city):
    """
    Fetch weather data for a given city from the OpenWeatherMap API.
    
    Parameters:
        city (str): Name of the city
    
    Returns:
        dict: Weather data for the city or None if there's an error
    """
    logging.debug(f"fetch_weather_data called with city: {city}")
    api_key = os.getenv('API_KEY')
    url = f'https://api.openweathermap.org/data/2.5/weather?q={city}&appid={api_key}&units=metric'
    logging.debug(f"Constructed URL: {url}")

    # Make the API call and handle potential exceptions
    try:
        response = requests.get(url)
        logging.debug(f"Called requests.get with URL: {url}")
        
        # Check for 401 status code
        if response.status_code == 401:
            logging.error(f"Unauthorized access for city {city}. API key may be missing or invalid.")
            return None

        response.raise_for_status()
        json_data = response.json()
        logging.debug(f"Received JSON data for {city}: {json_data}")

        # Extract the necessary data from the response
        result = {
            'city': city,
            'temp': json_data['main']['temp'],
            'min_temp': json_data['main']['temp_min'],
            'max_temp': json_data['main']['temp_max'],
            'description': json_data['weather'][0]['description']
        }
        logging.debug(f"fetch_weather_data for {city} returned: {result}")
        return result
    except requests.HTTPError as http_err:
        logging.error(f"HTTP error occurred for city {city}: {http_err} - Status Code: {response.status_code}")
        return None
    except requests.RequestException as err:
        logging.error(f"Error fetching weather data for city {city}: {err}")
        return None
    except KeyError as e:
        logging.error(f"KeyError when parsing weather data for city {city}: {e}")
        return None
    
@app.route('/')
def index():
    """
    Home route that displays weather data for select cities.

    Returns:
        str: Rendered HTML page with weather data
    """
    logging.info(f'Request made to {request.url} from {request.remote_addr} using {request.headers.get("User-Agent")}')
    cities = ['New York', 'London', 'Paris']
    data = [fetch_weather_data(city) for city in cities]
    data = [city_data for city_data in data if city_data]  # Filter out None values

    # If not in testing mode, save the request data to MongoDB
    if os.getenv('TESTING') != 'true' and data:
        db = create_mongo_client()
        db.requests.insert_one({
            'ip_address': request.remote_addr,
            'user_agent': request.headers.get('User-Agent'),
            'weather_data': data
        })
    return render_template('weather.html', data=data)

# Run the app
if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port)