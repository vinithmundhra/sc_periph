import sys
import signal, os
import time
import threading

# Exit the program if Python version used is lower than 2.7.3
if sys.version_info < (2,7,3):
  print('Required Python version 2.7.3 or newer. Exiting!')
  exit(1)

if sys.version_info < (3,0,1):
  # Python version 2.x
  import SocketServer as socketserver
else:
  # Python version 3.x
  import socketserver

# Global variables
g_kb_interrupt = False
g_start_counter = 0
g_sleep_time = 30

# Check for valid IP address
def valid_ip(address):
  try:
    host_bytes = address.split('.')
    valid = [int(b) for b in host_bytes]
    valid = [b for b in valid if b >= 0 and b <= 255]
    return len(host_bytes) == 4 and len(valid) == 4
  except:
    return False

# Get the IP address to run the server on.
# This should be same as HOST computer's static IP address
try:
  g_HOST = sys.argv[1]
  if not valid_ip(g_HOST):
    exit(1)
except:
   print('Please enter a valid Web server IP address. Exiting!')
   exit(1)

# Keyboard interrupt handler
def kb_handler(signum, frame):
    global g_kb_interrupt
    g_kb_interrupt = True

signal.signal(signal.SIGINT, kb_handler)

# ----------------------------------------------------------------------------
# Counter - a thread to manage the sleep count-down
# ----------------------------------------------------------------------------
def counter():
  global g_sleep_time
  global g_start_counter

  while True:
    time.sleep(1)
    if g_start_counter == 1:
      if g_sleep_time >= 0:
        print(g_sleep_time)
        g_sleep_time -= 1
      else:
        print('Server: Sleep time exceeded. The chip should have woken up by now!')
        g_start_counter = 0
    if g_kb_interrupt:
      break


# ----------------------------------------------------------------------------
# The TCP handler - receive data from the device and print it on the console
# ----------------------------------------------------------------------------
class xmos_tcp_handler(socketserver.BaseRequestHandler):

  def handle(self):

    global g_start_counter
    global g_sleep_time

    while True:
      data = self.request.recv(1024).decode()
      g_start_counter = 0
      if data:
        for line in data.split('\n'):
          if line:
            print('XMOS: %s' % line)
      else:
        g_sleep_time = 30
        print('-----------------------------------------')
        print('Server: Client closed connection, expecting wakeup in %d seconds...' %
            g_sleep_time)
        self.request.close()
        g_start_counter = 1
        break

# ----------------------------------------------------------------------------
# start_server - wait until the link is up and then start listening
# ----------------------------------------------------------------------------
def start_server():

  PORT = 80

  print('Server: Waiting to start web server')
  print('Server: Press CTRL+C to exit.')

  while True:
    socketserver.TCPServer.allow_reuse_address = True
    try:
      server = socketserver.TCPServer((g_HOST, PORT), xmos_tcp_handler)
      print('Server: Web server started with IP address = %s' % g_HOST)
      print('-----------------------------------------')
      server.serve_forever()

    except KeyboardInterrupt:
      global g_kb_interrupt
      g_kb_interrupt = True
      server.socket.close()
      print('Server: Exiting')
      break

    except:
      # Wait and try again
      time.sleep(1)

# ----------------------------------------------------------------------------
# MAIN
# ----------------------------------------------------------------------------
if __name__ == "__main__":

  t_server = threading.Thread(target=start_server)
  t_server.setDaemon(True)
  t_server.start()

  t_counter = threading.Thread(target=counter)
  t_counter.start()

  while True:
    if g_kb_interrupt:
      t_counter.join()
      print('Server: Terminating...')
      break
    pass

