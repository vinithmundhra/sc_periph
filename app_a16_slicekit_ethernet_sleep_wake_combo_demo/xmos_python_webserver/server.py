#!/usr/bin/python
import socket,sys

server_port = 501
self_ip = socket.gethostbyname(socket.gethostname())
print >>sys.stderr, 'Server Address = ', self_ip

server_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server_sock.bind((self_ip, server_port))
server_sock.listen(1)

while 1:
  
  print "Waiting for a client connection..."
  connection, client_address = server_sock.accept()
  print >>sys.stderr, 'connection from', client_address
  
  data = connection.recv(100)
  print >>sys.stderr, '==> "%s"\n' % data
  connection.close()
  