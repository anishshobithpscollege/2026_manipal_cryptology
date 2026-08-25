import codecs
import socket

HOST = "127.0.0.1"
PORT = 65432

server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
server.bind((HOST, PORT))
server.listen()
print(f"Server listening on {HOST}:{PORT}")

connection, address = server.accept()
print("Connected by", address)
data = connection.recv(1024).decode()
print("Received :", data)

reply = codecs.encode(data, "rot_13")
connection.sendall(reply.encode())
print("Sent :", reply)

connection.close()
server.close()
