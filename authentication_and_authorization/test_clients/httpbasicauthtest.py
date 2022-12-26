import requests

# base url for the api
base_url = "http://localhost:8080/api"

# invoke a public API
resp = requests.get(base_url + "/public")
print(resp.text)  # OUT "Hello World! It's 15:26:29 in DMVCFrameworkland"

# invoke a private API without authentication
resp = requests.get(base_url + "/private/role1")
print(resp.text)  # OUT "401: Not authorized"

# invoke role1 API with authentication as user1/pwduser1 (ok)
resp = requests.get(base_url + "/private/role1", auth=('user1', 'pwduser1'))
print(resp.text)  # OUT "Response from ActionForRole1"

# invoke role2 API with authentication as user1/pwduser1 (error - forbidden)
resp = requests.get(base_url + "/private/role2", auth=('user1', 'pwduser1'))
print(resp.text)  # OUT {"status":"error", "message":"403: Forbidden"}

# invoke role2 API with authentication as user2/pwduser2 (ok)
resp = requests.get(base_url + "/private/role2", auth=('user2', 'pwduser2'))
print(resp.text)  # OUT Response from ActionForRole2

# invoke role1 API with authentication as user3/pwduser3 (ok)
resp = requests.get(base_url + "/private/role1", auth=('user3', 'pwduser3'))
print(resp.text)  # OUT Response from ActionForRole1

# invoke role2 API with authentication as user3/pwduser3 (ok)
resp = requests.get(base_url + "/private/role2", auth=('user3', 'pwduser3'))
print(resp.text)  # OUT Response from ActionForRole2
