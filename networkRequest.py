import requests
import threading

def send_request(url):
    while True:
        response = requests.get(url)
        print(response.status_code)

url = "http://example.com"  # Hedef URL
num_threads = 10  # Aynı anda çalışacak thread sayısı

# Belirli sayıda thread oluşturarak isteklerinizi artırabilirsiniz
for _ in range(num_threads):
    threading.Thread(target=send_request, args=(url,)).start()
