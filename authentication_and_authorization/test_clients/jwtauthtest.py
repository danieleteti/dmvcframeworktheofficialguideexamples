import requests

# base url for the api
base_url = "http://localhost:8080/api"

# invoke a public API
resp = requests.get(base_url + "/public")
print(resp.text)  # OUT => Hello World! It's 15:26:29 in DMVCFrameworkland

# invoke a private API without authentication
resp = requests.get(base_url + "/private/role1")
print(f"{resp.status_code}: {resp.reason}")  # OUT "401: Not authorized"
print(resp.json())  # OUT => <a json object describing the exception>

# Now, we do a request to get a JWT token for user1
resp = requests.get(base_url + "/login", auth=('user1', 'pwduser1'))
print(resp.text)  # OUT => {"token":"<thetoken>"}
# let's save the token to use it in next calls...
jwt_token = resp.json()["token"]
# now this token must be injected in the request headers...
# let's prepare the headers...

req_headers = {}  # this is a dictionary
req_headers["Authorization"] = "Bearer " + jwt_token

# invoke role1 API with the token generated for user1
resp = requests.get(base_url + "/private/role1", headers=req_headers)
print(resp.text)  # OUT "Response from ActionForRole1"

# invoke role2 API with the token generated for user1 (error)
resp = requests.get(base_url + "/private/role2", req_headers)
print(resp.text)  # OUT Authorization Required

# Now, we do a request to get a JWT token for user2
resp = requests.get(base_url + "/login", auth=('user2', 'pwduser2'))
# let's save the token to use it in next calls...
jwt_token = resp.json()["token"]
req_headers["Authorization"] = "Bearer " + jwt_token

# invoke role2 API with token generated for user2 (ok)
resp = requests.get(base_url + "/private/role2", headers=req_headers)
print(resp.text)  # OUT Response from ActionForRole2

# Now, we do a request to get a JWT token for user3
resp = requests.get(base_url + "/login", auth=('user3', 'pwduser3'))
# let's save the token to use it in next calls...
jwt_token = resp.json()["token"]
req_headers["Authorization"] = "Bearer " + jwt_token

# invoke role1 API with token generated for user3 (ok)
resp = requests.get(base_url + "/private/role1", headers=req_headers)
print(resp.text)  # OUT Response from ActionForRole1

# invoke role2 API with token generated for user3 (ok)
resp = requests.get(base_url + "/private/role2", headers=req_headers)
print(resp.text)  # OUT Response from ActionForRole2
