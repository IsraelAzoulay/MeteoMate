# Import necessary libraries and modules for integration testing
import os
import unittest
import responses
from pymongo import MongoClient
from app.app import app, fetch_weather_data
from dotenv import load_dotenv
from unittest.mock import patch, Mock
import certifi 

class IntegrationTestCase(unittest.TestCase):
    """
    Integration Test Case for the Flask application.
    """

    @classmethod
    def setUpClass(cls):
        """Class-wide setup method, executed once at the beginning of the test."""
        # Load environment variables
        load_dotenv()
        # Establish a connection to the MongoDB test instance
        connection_string = os.getenv('MONGODB_TESTS_URI')
        cls.client = MongoClient(connection_string)  
        cls.db = cls.client["test_database"]

    def setUp(self):
        """Setup method. Executed before every test."""
        app.config['TESTING'] = False
        self.app = app.test_client()

    @responses.activate
    def test_integration(self):
        """
        Test the integration of the application with mocked API responses 
        while connecting to the real database.
        """
        cities = ['New York', 'London', 'Paris']
        # Mock the API responses for each city
        for city in cities:
            responses.add(
                responses.GET,
                f'https://api.openweathermap.org/data/2.5/weather?q={city}&appid={os.environ["API_KEY"]}&units=metric',
                json={
                    'main': {
                        'temp': 20.0,
                        'temp_min': 15.0,
                        'temp_max': 25.0
                    },
                    'weather': [{'description': 'clear sky'}]
                },
                status=200
            )
        # Mock the MongoDB client to use the test database
        with patch('app.app.create_mongo_client') as mock_mongo_client:
            mock_mongo_client.return_value = self.db
            response = self.app.get('/')
            self.assertEqual(response.status_code, 200)

        # Verify data was stored in the test database
        request_data = self.db.requests.find_one()
        self.assertIsNotNone(request_data)
        self.db.requests.drop()

    @responses.activate
    def test_integration_api_error(self):
        """
        Test the behavior of the application when the weather API returns an error.
        """
        cities = ['New York', 'London', 'Paris']
        # Mock error responses for the API
        for city in cities:
            responses.add(
                responses.GET,
                f'https://api.openweathermap.org/data/2.5/weather?q={city}&appid={os.environ["API_KEY"]}&units=metric',
                json={"message": "API error"},
                status=500
            )
        # Mock the MongoDB client to use the test database
        with patch('app.app.create_mongo_client') as mock_mongo_client:
            mock_mongo_client.return_value = self.db
            response = self.app.get('/')
            # The application should handle API errors gracefully
            self.assertEqual(response.status_code, 200)

    @patch('app.app.create_mongo_client', side_effect=Exception("DB error"))
    def test_integration_db_unreachable(self, _):
        """Test behavior when the MongoDB is unreachable."""
        response = self.app.get('/')
        # Even if the database is unreachable, the application should handle gracefully and still return a 200 status
        self.assertEqual(response.status_code, 200)

    @classmethod
    def tearDownClass(cls):
        """Class-wide teardown method, executed once at the end of the test."""
        # Drop all collections from the test database
        for collection in cls.db.list_collection_names():
            cls.db[collection].drop()

if __name__ == "__main__":
    unittest.main()