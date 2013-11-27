import sys
import signal, os
import time
import threading

# Exit the program if Python version used is lower than 2.7.3
if sys.version_info < (2,7,3):
  print('Required Python version 2.7.3 or newer. Exiting!')
  exit(1)

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

if sys.version_info < (3,0,1):

  # ----------------------------------------------------------------------------
  # ----------------------------------------------------------------------------
  # Python version 2.x
  # ----------------------------------------------------------------------------
  # ----------------------------------------------------------------------------
  import SocketServer
  # ----------------------------------------------------------------------------
  # The TCP handler
  # ----------------------------------------------------------------------------
      
  class xmos_tcp_handler(SocketServer.BaseRequestHandler):

    def handle(self):

      global g_start_counter
      global g_sleep_time

      while True:
        data = self.request.recv(1024).decode()
        g_start_counter = 0
        if data:
          print('XMOS: %s' % data)
        else:
          print('-----------------------------------------')
          print('Expecting Wakeup in (seconds)...')          
          g_sleep_time = 30          
          g_start_counter = 1
          self.request.close()
          break

  # ----------------------------------------------------------------------------
  # start_server
  # ----------------------------------------------------------------------------
  def start_server():

    global g_HOST
    PORT = 80
         
    SocketServer.TCPServer.allow_reuse_address = True
    try:
      server = SocketServer.TCPServer((g_HOST, PORT), xmos_tcp_handler)
      print('-----------------------------------------')
      print('Web Server Address = %s' % g_HOST)
      print('Press CTRL+C to stop web server and exit.')
      print('-----------------------------------------')      
    except:
      print('-----------------------------------------')
      print('Error creating a socket. Please switch ON the device connected to Ethernet port or check if the IP address given is same as your computers static IP configuration of Wired connection.')
      global g_kb_interrupt
      g_kb_interrupt = True

    try:
      server.serve_forever()
    except KeyboardInterrupt:
      server.socket.close()
      
  # ----------------------------------------------------------------------------
  # Counter
  # ----------------------------------------------------------------------------
  def counter():

    global g_sleep_time
    global g_start_counter

    while True:
      if g_start_counter == 1:
        if g_sleep_time > 0:
          print(g_sleep_time)
          g_sleep_time -= 1
          time.sleep(1)
        else:
          print('Sleep time exceeded. The chip should have woken up by now!')
          g_start_counter = 0
      if g_kb_interrupt:
        break

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
        print('Terminating...')
        break
      pass

else:

  # ----------------------------------------------------------------------------
  # ----------------------------------------------------------------------------
  # Python version 3.x
  # ----------------------------------------------------------------------------
  # ----------------------------------------------------------------------------
  import socketserver
  # ----------------------------------------------------------------------------
  # The TCP handler
  # ----------------------------------------------------------------------------
  class xmos_tcp_handler(socketserver.BaseRequestHandler):

    def handle(self):

      global g_start_counter
      global g_sleep_time

      while True:
        data = self.request.recv(1024).decode()
        g_start_counter = 0
        if data:
          print('XMOS: %s' % data)
        else:
          print('-----------------------------------------')
          print('Expecting Wakeup in (seconds)...')          
          g_sleep_time = 30          
          g_start_counter = 1
          self.request.close()
          break

  # ----------------------------------------------------------------------------
  # start_server
  # ----------------------------------------------------------------------------
  def start_server():

    global g_HOST
    PORT = 80

    socketserver.TCPServer.allow_reuse_address = True
    try:
      server = socketserver.TCPServer((g_HOST, PORT), xmos_tcp_handler)
      print('-----------------------------------------')
      print('Web Server Address = %s' % g_HOST)
      print('Press CTRL+C to stop web server and exit.')
      print('-----------------------------------------')    
    except:
      print('-----------------------------------------')
      print('Error creating a socket. Please switch ON the device connected to Ethernet port or check if the IP address given is same as your computers static IP configuration of Wired connection.')
      global g_kb_interrupt
      g_kb_interrupt = True      

    try:
      server.serve_forever()
    except KeyboardInterrupt:
      server.socket.close()

  # ----------------------------------------------------------------------------
  # Counter
  # ----------------------------------------------------------------------------
  def counter():

    global g_sleep_time
    global g_start_counter

    while True:
      if g_start_counter == 1:
        if g_sleep_time > 0:
          print(g_sleep_time)
          g_sleep_time -= 1
          time.sleep(1)
        else:
          print('Sleep time exceeded. The chip should have woken up by now!')
          g_start_counter = 0
      if g_kb_interrupt:
        break
        
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
        print('Terminating...')
        break
      pass
      
