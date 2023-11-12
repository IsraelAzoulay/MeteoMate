# Import necessary libraries and modules for testing
from unittest.mock import patch, MagicMock
import os
import unittest
from pymongo import MongoClient
from app.app import app, create_mongo_client, fetch_weather_data
from dotenv import load_dotenv
import certifi

class AppTestCase(unittest.TestCase):
    """
    Test case for the Flask application.
    """

    @classmethod
    @patch('pymongo.MongoClient')
    def setUpClass(cls, mock_mongo_client):
        """Class-wide setup method. Executed once at the beginning of the test."""
        cls.db = MagicMock()
        mock_mongo_client.return_value = cls.db

    def setUp(self):
        """Setup method. Executed before every test."""
        app.config['TESTING'] = True
        self.app = app.test_client()
        fetch_weather_data.cache_clear()  # Clear the cache before each test

    @patch('app.app.create_mongo_client')
    def test_index(self, mock_mongo_client):
        """
        Test successful retrieval of weather data and rendering of the main page.
        """
        with patch('app.app.fetch_weather_data') as mock_fetch:
            mock_fetch.return_value = {
                'temperature': 20,
                'description': 'cloudy',
                'city': 'London'
            }
            mock_mongo_client.return_value = self.db
            response = self.app.get('/')
            self.assertEqual(response.status_code, 200)

    @patch('pymongo.MongoClient')
    def test_create_mongo_client(self, mock_mongo_client):
        """Test the MongoDB client creation function."""
        mock_mongo_client.return_value = self.db
        db = create_mongo_client()
        self.assertIsNotNone(db)

    @patch('requests.get')
    def test_fetch_weather_data_success(self, mock_get):
        """Test successful fetch of weather data from the API."""
        mock_response = MagicMock()
        mock_response.status_code = 200
        mock_response.json.return_value = {
            'main': {
                'temp': 20.0,
                'temp_min': 15.0,
                'temp_max': 25.0
            },
            'weather': [{'description': 'clear sky'}]
        }
        mock_get.return_value = mock_response
        city = "London"
        data = fetch_weather_data(city)
        print("DATA RETURNED:", data)  # Add this print statement for debugging
        mock_get.assert_called_once()  # Ensure the mock is triggered
        self.assertIsNotNone(data, "Expected data to be a dictionary, but got None.")
        self.assertEqual(data["city"], city)

    @patch('app.app.requests.get')
    def test_fetch_weather_data_missing_api_key(self, mock_get):
        """Test fetch of weather data without an API key."""
        mock_response = MagicMock()
        mock_response.status_code = 401  # Unauthorized status
        mock_response.json.return_value = {"message": "API key missing or invalid"}
        mock_get.return_value = mock_response
        city = "London"
        data = fetch_weather_data(city)
        self.assertIsNone(data)

    @patch('app.app.requests.get')
    def test_fetch_weather_data_invalid_city(self, mock_get):
        """Test fetch of weather data with an invalid city."""
        mock_response = MagicMock()
        mock_response.status_code = 404  # Not Found status
        mock_response.json.return_value = {"message": "city not found"}
        mock_get.return_value = mock_response
        city = "InvalidCity"
        data = fetch_weather_data(city)
        mock_get.assert_called_once_with(f'https://api.openweathermap.org/data/2.5/weather?q={city}&appid={os.getenv("API_KEY")}&units=metric')
        self.assertIsNone(data)

    @patch('app.app.requests.get')
    def test_fetch_weather_data_api_response_change(self, mock_get):
        """Test behavior when API response structure changes."""
        mock_response = MagicMock()
        mock_response.status_code = 200
        mock_response.json.return_value = {
            'main': {
                'temp': 20.0,
                'temp_min': 15.0,
                'temp_max': 25.0
            }
        }
        mock_get.return_value = mock_response
        city = "London"
        data = fetch_weather_data(city)
        self.assertIsNone(data)

    @classmethod
    @patch('pymongo.MongoClient')
    def tearDownClass(cls, mock_mongo_client):
        """Class-wide teardown method. Executed once at the end of the test."""
        mock_mongo_client.return_value = cls.db

if __name__ == "__main__":
    unittest.main()