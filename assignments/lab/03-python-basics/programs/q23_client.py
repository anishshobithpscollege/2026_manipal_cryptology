import socket

HOST = "127.0.0.1"
PORT = 65432
MESSAGE = "HELLO SERVER"

client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
client.connect((HOST, PORT))
client.sendall(MESSAGE.encode())
print("Sent :", MESSAGE)

reply = client.recv(1024).decode()
print("Received :", reply)

client.close()
