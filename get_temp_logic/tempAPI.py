import os
import requests
import time
from prometheus_client import start_http_server, Gauge

API_KEY = os.environ.get('OPENWEATHER_API_KEY') # Ensure you set this environment variable with your OpenWeatherMap API key
CITY = 'Tallinn'
URL = f'http://api.openweathermap.org/data/2.5/weather?q={CITY}&appid={API_KEY}&units=metric'

# Create a Prometheus Gauge metric for temperature
temperature_gauge = Gauge('current_temperature', 'Current temperature in Tallinn (°C)')

# Function to fetch temperature data from OpenWeatherMap API
def fetch_temperature():
    try:
        response = requests.get(URL)
        response.raise_for_status()  # Raise an error for bad responses
        data = response.json()
        temperature = data['main']['temp']
        temperature_gauge.set(temperature)
    except requests.RequestException as e:
        print(f"Error fetching data: {e}")
        return None

if __name__ == '__main__':    
    #start http server for Prometheus metrics
    start_http_server(5000)

    # Fetch temperature data periodically
    while True:
        fetch_temperature()
        time.sleep(5)