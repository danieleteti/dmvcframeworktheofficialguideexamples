import requests

# base url for the api
base_url = "http://localhost:8080/api"


def print_books(books):
    print("-" * 71)
    print('| {:<60} | {:<4} |'.format("TITLE", "YEAR"))
    print("-" * 71)
    for book in books:
        print('| {title:<60} | {pubYear:<4} |'.format_map(book))


def get_token(email, password):
    # Execute login with an employee account
    resp = requests.get(base_url + "/login", auth=(email, password))

    # let's save the token to use it in next calls...
    jwt_token = resp.json()["token"]
    # now this token must be injected in the request headers...
    return jwt_token


def get_books(token):
    # let's prepare the headers...
    req_headers = {
        "Authorization": "Bearer " + token
    }
    # invoke /api/books API with the token
    resp = requests.get(base_url + "/books", headers=req_headers)
    return resp.json()["data"]


def main():
    token = get_token('daniele@library.com', 'a')
    books = get_books(token)
    print_books(books)


if __name__ == '__main__':
    main()
