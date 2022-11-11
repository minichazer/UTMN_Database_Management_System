import uuid
import time

start = time.time()
lst = []
while True:
    if time.time() - start > 1:
        break
    lst.append(uuid.uuid4())
    #print(uuid.uuid4())

print(f"Total generated UUIDs (1 sec): {len(lst)}")
a = input()
#print(lst)