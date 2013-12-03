#ifndef __ethernet_board_conf_h__
#define __ethernet_board_conf_h__



#define ETHERNET_DEFAULT_PHY_ADDRESS 0

#define SMI_COMBINE_MDC_MDIO 1
#define SMI_MDC_BIT 0
#define SMI_MDIO_BIT 1
#define ETHERNET_DEFAULT_TILE tile[1]
#define PORT_ETH_RXCLK on tile[1]: XS1_PORT_1B
#define PORT_ETH_RXD on tile[1]: XS1_PORT_4A
#define PORT_ETH_TXD on tile[1]: XS1_PORT_4B
#define PORT_ETH_RXDV on tile[1]: XS1_PORT_1C
#define PORT_ETH_TXEN on tile[1]: XS1_PORT_1F
#define PORT_ETH_TXCLK on tile[1]: XS1_PORT_1G
#define PORT_ETH_MDIOC on tile[1]: XS1_PORT_4C
#define PORT_ETH_MDIOFAKE on tile[1]: XS1_PORT_8A
#define PORT_ETH_ERR on tile[1]: XS1_PORT_4D

#ifndef ETHERNET_DEFAULT_CLKBLK_0
#define ETHERNET_DEFAULT_CLKBLK_0 on ETHERNET_DEFAULT_TILE: XS1_CLKBLK_1
#endif

#ifndef ETHERNET_DEFAULT_CLKBLK_1
#define ETHERNET_DEFAULT_CLKBLK_1 on ETHERNET_DEFAULT_TILE: XS1_CLKBLK_2
#endif

#ifndef PORT_ETH_FAKE
#define PORT_ETH_FAKE on ETHERNET_DEFAULT_TILE: XS1_PORT_8C
#endif

#define ETHERNET_DEFAULT_MII_INIT_lite { \
  ETHERNET_DEFAULT_CLKBLK_0, \
  ETHERNET_DEFAULT_CLKBLK_1, \
\
    PORT_ETH_RXCLK,                             \
    PORT_ETH_ERR,                               \
    PORT_ETH_RXD,                               \
    PORT_ETH_RXDV,                              \
    PORT_ETH_TXCLK,                             \
    PORT_ETH_TXEN,                              \
    PORT_ETH_TXD,                               \
    PORT_ETH_FAKE \
}

#define ETHERNET_DEFAULT_SMI_INIT {ETHERNET_DEFAULT_PHY_ADDRESS, \
                                   PORT_ETH_MDIOC}

#endif // __ethernet_board_conf_h__
