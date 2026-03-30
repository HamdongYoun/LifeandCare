import requests

def test_hospitals():
    try:
        # We need to run the server first, but for verification of code logic, 
        # we can just import the function or run the command if the server is running.
        # However, I'll assume the server might already be running or I'll run it.
        # Let's try to hit the endpoint assuming it's up on port 8000.
        params = {"lat": 37.5665, "lng": 126.9780, "query": "내과"}
        response = requests.get("http://localhost:8001/hospitals", params=params)
        data = response.json()
        print(f"Count: {len(data)}")
        for i, h in enumerate(data):
            print(f"{i+1}: {h['name']} - {h['dist']}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    test_hospitals()
