import requests

api_url = "http://api.zippopotam.us/IT/00100"

headers = {
    'content-type': "application/json",
    'accept': "application/json"
}

resp = requests.get(api_url, headers=headers)

print('** response body as text')
print(resp.text)

print('** response body as json (if possible) - fails if body is not a valid json')
print(resp.json())

print('** response headers')
print(resp.headers)

print('** response HTTP status_code')
print(resp.status_code)

print('** response HTTP status_text (or "reason")')
print(resp.reason)

print('** response cookies')
print(resp.cookies.get_dict())
