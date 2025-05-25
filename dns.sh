opkg update && opkg install wget
mkdir /opt/ && cd /opt/
wget -c https://static.adguard.com/adguardhome/release/AdGuardHome_linux_arm64.tar.gz
tar xfvz AdGuardHome_linux_arm64.tar.gz
rm AdGuardHome_linux_arm64.tar.gz
/opt/AdGuardHome/AdGuardHome -s install

uci -q delete firewall.dns_int
uci set firewall.dns_int="redirect"
uci set firewall.dns_int.name="Intercept-DNS"
uci set firewall.dns_int.src="lan"
uci set firewall.dns_int.src_dport="53"
uci set firewall.dns_int.proto="tcp udp"
uci set firewall.dns_int.target="DNAT"
# Also intercept IPv6 DNS traffic
uci set firewall.dns_int.family="any"
uci commit firewall
/etc/init.d/firewall restart

NET_ADDR=$(/sbin/ip -o -4 addr list br-lan | awk 'NR==1{ split($4, ip_addr, "/"); print ip_addr[1]; exit }')
NET_ADDR6=$(/sbin/ip -o -6 addr list br-lan scope global | awk '$4 ~ /^fd|^fc/ { split($4, ip_addr, "/"); print ip_addr[1]; exit }')
echo "Router IPv4 : ""${NET_ADDR}"
echo "Router IPv6 : ""${NET_ADDR6}"
 
# 1. Move dnsmasq to port 54.
# 2. Set local domain to "lan".
# 3. Add local '/lan/' to make sure all queries *.lan are resolved in dnsmasq;
# 4. Add expandhosts '1' to make sure non-expanded hosts are expanded to ".lan";
# 5. Disable dnsmasq cache size as it will only provide PTR/rDNS info, making sure queries are always up to date (even if a device internal IP change after a DHCP lease renew).
# 6. Disable reading /tmp/resolv.conf.d/resolv.conf.auto file (which are your ISP nameservers by default), you don't want to leak any queries to your ISP.
# 7. Delete all forwarding servers from dnsmasq config.
uci set dhcp.@dnsmasq[0].port="54"
uci set dhcp.@dnsmasq[0].domain="lan"
uci set dhcp.@dnsmasq[0].local="/lan/"
uci set dhcp.@dnsmasq[0].expandhosts="1"
uci set dhcp.@dnsmasq[0].cachesize="0"
uci set dhcp.@dnsmasq[0].noresolv="1"
uci -q del dhcp.@dnsmasq[0].server
 
# Delete existing config ready to install new options.
uci -q del dhcp.lan.dhcp_option
uci -q del dhcp.lan.dns
 
# DHCP option 3: Specifies the gateway the DHCP server should send to DHCP clients.
uci add_list dhcp.lan.dhcp_option='3,'"${NET_ADDR}"
 
# DHCP option 6: Specifies the DNS server the DHCP server should send to DHCP clients.
uci add_list dhcp.lan.dhcp_option='6,'"${NET_ADDR}" 
 
# DHCP option 15: Specifies the domain suffix the DHCP server should send to DHCP clients.
uci add_list dhcp.lan.dhcp_option='15,'"lan"
 
# Set IPv6 Announced DNS
uci add_list dhcp.lan.dns="$NET_ADDR6"
 
uci commit dhcp
service dnsmasq restart
service odhcpd restart
exit 0