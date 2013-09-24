#!/usr/bin/python
import socket,sys

def valid_ip(address):
  try:
    host_bytes = address.split('.')
    valid = [int(b) for b in host_bytes]
    valid = [b for b in valid if b >= 0 and b <= 255]
    return len(host_bytes) == 4 and len(valid) == 4
  except:
    return False
        
port = 501
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

try:
  server_ip = sys.argv[1]
  if not valid_ip(server_ip):
    exit(1)

except:
   print('Please enter a Web server IP address. For example: python test_client.py 172.17.0.15')
   exit(1)

print('Connecting..')
sock.connect((server_ip, port))
print('Connected')

msg = 'Hi from test client'
print('Sending message: %s' % msg)
sock.sendall(msg.encode())

print('Closing...')
sock.close()
print('Closed')

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

print('Connecting..')
sock.connect((server_ip, port))
print('Connected')

msg = 'Hi from test client'
print('Sending message: %s' % msg)
sock.sendall(msg.encode())

print('Closing...')
sock.close()
print('Closed')
    