import requests

url = "http://localhost:8080/api/users"

payload = {
    "email": "daniele@library.com",
    "pwd": "YQ=="
}
headers = {
    'content-type': "application/json",
    'accept': "application/json"
}

response = requests.request("POST", url, json=payload, headers=headers)

print(f"{response.status_code}: {response.reason}")
print(response.text)
