#!/bin/sh
sudo modprobe ipt_owner

#mark packages
sudo iptables -t mangle -A OUTPUT -m owner --uid-owner pdns -j MARK --set-mark 1
sudo iptables -t mangle -A OUTPUT -m owner --uid-owner ntp -j MARK --set-mark 1
sudo iptables -t mangle -A OUTPUT -p udp -m udp --sport 123 --dport 123 -j MARK --set-mark 1
sudo iptables -t mangle -A OUTPUT -p tcp -m tcp --dport 25 -j MARK --set-mark 1

#create mark-routing-table
#echo "1 special" | sudo tee -a /etc/iproute2/rt_tables > /dev/null
sudo ip rule add from all fwmark 1 table special
sudo ip route add default via 10.41.217.9 table special
#dev tun0 
sudo iptables -t nat -A POSTROUTING -o tun0 -j MASQUERADE

#mentioned in http://arstechnica.com/civis/viewtopic.php?f=16&t=1195455
echo 2 | sudo tee /proc/sys/net/ipv4/conf/tun0/rp_filter

#modify main routing-table
sudo route add -net default gateway 192.168.178.5
sudo route del -net default gateway 10.41.217.9
sudo route add -net 192.168.100.0/24 gateway 10.41.217.9;


#ipv6
sudo ifconfig tun0 inet6 add 2a01:4f8:201:4108:2:1:0:1003/96
sudo route --inet6 add ::/0 gw 2a01:4f8:201:4108:2:1:0:3
exit

#to restore after suspend or other reconnect:

sudo ip route add default via 10.41.217.9 table special
echo 2 | sudo tee /proc/sys/net/ipv4/conf/tun0/rp_filter
sudo route add -net default gateway 192.168.178.5
sudo route del -net default gateway 10.41.217.9
sudo route add -net 192.168.100.0/24 gateway 10.41.217.9;
sudo ifconfig tun0 inet6 add 2a01:4f8:201:4108:2:1:0:1003/96
sudo route --inet6 add ::/0 gw 2a01:4f8:201:4108:2:1:0:3