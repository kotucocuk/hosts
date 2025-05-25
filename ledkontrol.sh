#!/bin/sh

ACTION=$1

if [ "$ACTION" = "open" ]; then
    uci set system.led_wan.name='WAN'
    uci set system.led_wan.sysfs='green:wan'
    uci set system.led_wan.trigger='netdev'
    uci set system.led_wan.device='eth0'
    uci set system.led_wan.dev='eth0'
    uci del system.led_wan.mode
    uci add_list system.led_wan.mode='link'

    uci set system.led_lan1.name='LAN1'
    uci set system.led_lan1.sysfs='green:lan-1'
    uci set system.led_lan1.trigger='netdev'
    uci set system.led_lan1.dev='eth1'
    uci del system.led_lan1.mode
    uci add_list system.led_lan1.mode='link'

    uci set system.led_lan2.name='LAN2'
    uci set system.led_lan2.sysfs='green:lan-2'
    uci set system.led_lan2.trigger='netdev'
    uci set system.led_lan2.dev='eth2'
    uci del system.led_lan2.mode
    uci add_list system.led_lan2.mode='link'

    uci commit system
    /etc/init.d/led restart

elif [ "$ACTION" = "close" ]; then
    uci set system.led_wan.name='WAN'
    uci set system.led_wan.sysfs='green:wan'
    uci set system.led_wan.trigger='netdev'
    uci set system.led_wan.device='eth0'
    uci set system.led_wan.dev='eth0'
    uci del system.led_wan.mode

    uci set system.led_lan1.name='LAN1'
    uci set system.led_lan1.sysfs='green:lan-1'
    uci set system.led_lan1.trigger='netdev'
    uci set system.led_lan1.dev='eth1'
    uci del system.led_lan1.mode


    uci set system.led_lan2.name='LAN2'
    uci set system.led_lan2.sysfs='green:lan-2'
    uci set system.led_lan2.trigger='netdev'
    uci set system.led_lan2.dev='eth2'
    uci del system.led_lan2.mode

    uci commit system
    /etc/init.d/led restart
else
    exit 1
fi
