#!/usr/bin/python
import socket

server_port = 501
self_ip = socket.gethostbyname(socket.gethostname())
print 'Server Address = %s' % self_ip

server_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server_sock.bind((self_ip, server_port))
server_sock.listen(1)

while 1:

  conn, client_address = server_sock.accept()
  
  while 1:
    data = conn.recv(100)  
    if data:
      print 'XMOS: %s' % data
    else:
      print 'Connection closed'
      conn.close()
      break
