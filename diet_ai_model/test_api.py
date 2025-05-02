import requests

url = "http://127.0.0.1:5000/get_diet"

payload = {
    "age": 25,
    "gender": "Male",
    "height": 175,
    "weight": 70,
    "activity_level": "Moderately Active",
    "fitness_goal": "Muscle Gain",
    "dietary_preference": "Non-Vegetarian"
}

response = requests.post(url, json=payload)
print(response.status_code)
print(response.json())
