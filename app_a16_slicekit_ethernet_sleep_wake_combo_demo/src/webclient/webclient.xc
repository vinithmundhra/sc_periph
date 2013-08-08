// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*===========================================================================
 Info
 ----
 
 ===========================================================================*/

/*---------------------------------------------------------------------------
 include files
 ---------------------------------------------------------------------------*/
#include "webclient.h"
#include <string.h>

/*---------------------------------------------------------------------------
 constants
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 ports and clocks
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 typedefs
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 global variables
 ---------------------------------------------------------------------------*/
server_config_t server_cfg;
xtcp_connection_t conn;

/*---------------------------------------------------------------------------
 static variables
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 static prototypes
 ---------------------------------------------------------------------------*/

/*==========================================================================*/
/**
 *  Send data to the webserver.
 *
 *  \param c_xtcp   channel XTCP
 *  \param buf      character array containing data
 *  \param len      data length
 *  \return         1 for success, 0 for failure
 **/
static int webclient_send(chanend c_xtcp, unsigned char buf[], int len)
{
  int finished = 0;
  int success = 1;
  int index = 0, prev = 0;
  int id = conn.id;

  xtcp_init_send(c_xtcp, conn);

  while(!finished)
  {
    slave xtcp_event(c_xtcp, conn);

    switch(conn.event)
    {
      case XTCP_NEW_CONNECTION: xtcp_close(c_xtcp, conn); break;
      case XTCP_REQUEST_DATA:
      case XTCP_SENT_DATA:
      {
        int sendlen = (len - index);
        if (sendlen > conn.mss)
        sendlen = conn.mss;

        xtcp_sendi(c_xtcp, buf, index, sendlen);
        prev = index;
        index += sendlen;
        if (sendlen == 0)
        {
          finished = 1;
        }
        break;
      }

      case XTCP_RESEND_DATA: xtcp_sendi(c_xtcp, buf, prev, (index-prev)); break;
      case XTCP_RECV_DATA:
      {
        slave
        {
          c_xtcp <: 0;
        } // delay packet receive

        if (prev != len)
        success = 0;
        finished = 1;
        break;
      }
      case XTCP_TIMED_OUT:
      case XTCP_ABORTED:
      case XTCP_CLOSED:
      {
        if (conn.id == id)
        {
          finished = 1;
          success = 0;
        }
        break;
      }
      case XTCP_IFDOWN:
      {
        finished = 1;
        success = 0;
        break;
      }
    }
  }
  return success;
}

/*==========================================================================*/
/**
 *  Receive data from xtcp connection.
 *
 *  \param c_xtcp   channel XTCP
 *  \param buf      character array for received data
 *  \param minlen   minimum data length to receive
 *  \return         The number of bytes received
 **/
static int webclient_read(chanend c_xtcp, unsigned char buf[], int minlen)
{
  int rlen = 0;
  int id = conn.id;
  while(rlen < minlen)
  {
    slave xtcp_event(c_xtcp, conn);
    switch(conn.event)
    {
      case XTCP_NEW_CONNECTION: xtcp_close(c_xtcp, conn); break;
      case XTCP_RECV_DATA:
      {
        int n;
        n = xtcp_recvi(c_xtcp, buf, rlen);
        rlen += n;
        break;
      }
      case XTCP_REQUEST_DATA:
      case XTCP_SENT_DATA:
      case XTCP_RESEND_DATA: xtcp_send(c_xtcp, null, 0); break;

      case XTCP_TIMED_OUT:
      case XTCP_ABORTED:
      case XTCP_CLOSED:
      {
        if (conn.id == id) return -1;
        break;
      }
      case XTCP_IFDOWN: return -1; break;
    }
  }
  return rlen;
}

/*---------------------------------------------------------------------------
 webclient_set_server_config
 ---------------------------------------------------------------------------*/
void webclient_set_server_config(server_config_t server_config)
{
  server_cfg.server_ip[0] = server_config.server_ip[0];
  server_cfg.server_ip[1] = server_config.server_ip[1];
  server_cfg.server_ip[2] = server_config.server_ip[2];
  server_cfg.server_ip[3] = server_config.server_ip[3];
  server_cfg.tcp_in_port = server_config.tcp_in_port;
  server_cfg.tcp_out_port = server_config.tcp_out_port;
}

/*---------------------------------------------------------------------------
 webclient_init
 ---------------------------------------------------------------------------*/
void webclient_init(chanend c_xtcp)
{
  conn.event = XTCP_ALREADY_HANDLED;
  do
  {
    slave xtcp_event(c_xtcp, conn);
  } while(conn.event != XTCP_IFUP);
}

/*---------------------------------------------------------------------------
 webclient_connect_to_server
 ---------------------------------------------------------------------------*/
void webclient_connect_to_server(chanend c_xtcp)
{
  xtcp_listen(c_xtcp, server_cfg.tcp_in_port, XTCP_PROTOCOL_TCP);
  xtcp_connect(c_xtcp, server_cfg.tcp_out_port, server_cfg.server_ip, XTCP_PROTOCOL_TCP);

  conn.event = XTCP_ALREADY_HANDLED;
  do
  {
    slave xtcp_event(c_xtcp, conn);
  } while(conn.event != XTCP_NEW_CONNECTION);

}

/*---------------------------------------------------------------------------
 webclient_send_data
 ---------------------------------------------------------------------------*/
int webclient_send_data(chanend c_xtcp, char data[])
{
  return webclient_send(c_xtcp, data, strlen(data));
}

/*---------------------------------------------------------------------------
 webclient_request_close
 ---------------------------------------------------------------------------*/
void webclient_request_close(chanend c_xtcp)
{
  char dummy_data[1];
  xtcp_write(c_xtcp, conn, dummy_data, 0);
  xtcp_close(c_xtcp, conn);
  // Wait till the connection is closed
  conn.event = XTCP_ALREADY_HANDLED;
  do
  {
    slave xtcp_event(c_xtcp, conn);
  } while(conn.event != XTCP_CLOSED);
}

/*==========================================================================*/
