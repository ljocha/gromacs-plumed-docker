#!/usr/bin/env python3

import os
import socket

socket_path = "podmand.sock"

#podman = "podman"
podman = "echo"

server = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
try:
	os.remove(socket_path)
except FileNotFoundError:
	pass

server.bind(socket_path)
server.listen()

while True:
	conn,_addr = server.accept()
	cmd = conn.recv(1024).decode('utf-8')
	if not cmd:
		break
	else:
		os.system(podman + " " + cmd)
		conn.send("done".encode('utf-8'))
		

server.close()
os.remove(socket_path)

