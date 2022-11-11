import requests
import json

me = ""


SITE_URL = "http://shikimori.one"
PARAMS = {}
users = ["minichazer", "hitsedesen"]
for user in users:
    url = SITE_URL + f"/api/users/{user}/anime_rates?limit=200"
    # req = "api/users"
    r = requests.get(
        url=url, 
        headers={
            "User-Agent":"Api Test", 
            "Authorization":"seYKZAuV4gXDr-IHZ9ehjZZW13vWyLWLVBqzfHuVd-E"
            })

    data = r.json()
    with open(f"{user}.json", 'w', encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=4)
    # print(f"For user {user} data is:\n{data}")

#print(data)




# auth-code = fwIg5okvct-KTd766JbexWKRWaMv4LPnbjMFCYNjRdk
# req-token = seYKZAuV4gXDr-IHZ9ehjZZW13vWyLWLVBqzfHuVd-E