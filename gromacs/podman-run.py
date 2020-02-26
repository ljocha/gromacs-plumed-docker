#!/usr/bin/env python3

import socket
import os
import sys

socket_path = "podmand.sock"

client = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
client.connect(socket_path)

client.send(" ".join(sys.argv[1:]).encode('utf-8'))

reply = client.recv(1000)

print(reply)
client.close()
