// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*===========================================================================
 Info
 ----

 ===========================================================================*/

#ifndef __util_h__
#define __util_h__

/*---------------------------------------------------------------------------
 nested include files
 ---------------------------------------------------------------------------*/
#include <xccompat.h>
#include "common.h"

/*---------------------------------------------------------------------------
 constants
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 typedefs
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 global variables
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 extern variables
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 prototypes
 ---------------------------------------------------------------------------*/

/*==========================================================================*/
/**
 *  Copy Webserver configuration to character array
 *
 *  \param sconfig  Ref to webserver configuration (server_config_t)
 *  \param data[]   Ref to character array (char)
 *  \return None
 **/
void copy_server_config_to_char_array(REFERENCE_PARAM(server_config_t, sconfig), char data[]);

/*==========================================================================*/
/**
 *  Copy character array to Webserver configuration
 *
 *  \param sconfig  Ref to webserver configuration (server_config_t)
 *  \param data[]   Ref to character array (char)
 *  \return None
 **/
void copy_char_array_to_server_config(REFERENCE_PARAM(server_config_t, sconfig), char data[]);

#endif // __util_h__
/*==========================================================================*/
