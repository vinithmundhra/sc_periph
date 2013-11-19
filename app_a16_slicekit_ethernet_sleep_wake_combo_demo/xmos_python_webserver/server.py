import sys
import signal, os

kb_interrupt = False

def kb_handler(signum, frame):
    global kb_interrupt
    kb_interrupt = True

signal.signal(signal.SIGINT, kb_handler)

if sys.version_info < (2,7,3):
  print('Required Python version 2.7.3 or newer. Exiting!')
  exit(1)

from get_ip_address import get_ip_address    
  
if sys.version_info < (3,0,1):

  # ----------------------------------------------------------------------------
  # ----------------------------------------------------------------------------
  # Python version 2.x
  # ----------------------------------------------------------------------------
  # ----------------------------------------------------------------------------
  import SocketServer
  import time
  import threading
  from get_ip_address import get_ip_address

  # ----------------------------------------------------------------------------
  # Global variables
  # ----------------------------------------------------------------------------
  g_start_counter = 0
  g_sleep_time = 30

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

    HOST = get_ip_address()
    PORT = 80

    print('-----------------------------------------')
    print('Web Server Address = %s' % HOST)
    print('Press CTRL+C to stop web server and exit.')
    print('-----------------------------------------')
             
    SocketServer.TCPServer.allow_reuse_address = True
    server = SocketServer.TCPServer((HOST, PORT), xmos_tcp_handler)
    
    # TODO: Keyboard interrupt doesn't work here!
    # Hence, the socket doen't close properly and appear as 'Address already in
    # use' when calling this script again
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
      if kb_interrupt:
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
      if kb_interrupt:
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
  import time
  import threading
  from get_ip_address import get_ip_address

  # ----------------------------------------------------------------------------
  # Global variables
  # ----------------------------------------------------------------------------
  g_start_counter = 0
  g_sleep_time = 30

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

    HOST = get_ip_address()
    PORT = 80

    print('-----------------------------------------')
    print('Web Server Address = %s' % HOST)
    print('Press CTRL+C to stop web server and exit.')
    print('-----------------------------------------')

    socketserver.TCPServer.allow_reuse_address = True
    server = socketserver.TCPServer((HOST, PORT), xmos_tcp_handler)

    # TODO: Keyboard interrupt doesn't work here!
    # Hence, the socket doen't close properly and appear as 'Address already in
    # use' when calling this script again
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
      if kb_interrupt:
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
      if kb_interrupt:
        t_counter.join()
        print('Terminating...')
        break
      pass
      
