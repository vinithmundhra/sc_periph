#!/usr/bin/python
import asyncore
import socket

server_port = 501
self_ip = socket.gethostbyname(socket.gethostname())
print 'Server Address = %s' % self_ip

class XHandler(asyncore.dispatcher_with_send):

  def handle_read(self):
    data = self.recv(1024)
    if data:
      print 'XMOS: %s' % data
      
class XServer(asyncore.dispatcher):

  def __init__(self, host, port):
    asyncore.dispatcher.__init__(self)
    self.create_socket(socket.AF_INET, socket.SOCK_STREAM)
    self.set_reuse_addr()
    self.bind((host, port))
    self.listen(1)

  def handle_accept(self):
    pair = self.accept()
    if pair is not None:
      sock, addr = pair
      print 'Incoming %s' % repr(addr)
      handler = XHandler(sock)

server = XServer(self_ip, server_port)
asyncore.loop()
