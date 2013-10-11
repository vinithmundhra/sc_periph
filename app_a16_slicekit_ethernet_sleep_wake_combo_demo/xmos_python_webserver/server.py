#!/usr/bin/python
import socket
from get_ip_address import get_ip_address
  
server_port = 80
self_ip = get_ip_address()
print('Web Server Address = %s' % self_ip)

server_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server_sock.settimeout(1)
server_sock.bind((self_ip, server_port))
server_sock.listen(1)

conn_closed = 0

#This timeout should be same as the application sleep time
#But it would take some time for Ethernet link to come up. So, double this.
i = 20 

while True:
    
  try:  
    conn, client_address = server_sock.accept()
  except:
    if(conn_closed == 1):
      if(i >= 0):
        print(i, '...')
        i -= 1
      else:
        print('Time Exceeded')
      pass

  try:
    while True:
      data = conn.recv(1024).decode()  
      i = 20
      if data:
        print('XMOS: %s' % data)
      else:
        print('Connection closed')
        conn.close()
        conn_closed = 1
        print('Expecting Wakeup in (seconds)...')
        break
  except:
    pass
