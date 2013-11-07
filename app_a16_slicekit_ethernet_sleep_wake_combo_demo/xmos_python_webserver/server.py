#!/usr/bin/python
import socket
from get_ip_address import get_ip_address

#This timeout should be same as the application sleep time
#But it would take some time for Ethernet link to come up. So, double this.
i = 30
server_port = 80
conn_closed = 0

self_ip = get_ip_address()
print('-----------------------------------------')
print('Web Server Address = %s' % self_ip)
print('Press CTRL+C to stop web server and exit.')
print('-----------------------------------------')

while True:
  try:
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    s.settimeout(1)
    s.bind((self_ip, server_port))
    s.listen(1)

    while True:
      try:
        conn, client_address = s.accept()
        break
      except:
        if(conn_closed == 1):
          if(i > 0):
            print(i, '...')
            i -= 1
          else:
            print('Sleep time exceeded. The chip should have woken up by now!')
            conn_closed = 0
        pass

    while True:
      try:
        data = conn.recv(1024).decode()
        i = 30
        if data:
          print('XMOS: %s' % data)
        else:
          print('Expecting Wakeup in (seconds)...')
          conn_closed = 1
          conn.close()
          break
      except:
        pass

  except KeyboardInterrupt:
    try:
      conn.close()
    except:
      pass
    exit()
