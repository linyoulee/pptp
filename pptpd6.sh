mknod /dev/ppp c 108 0 
echo 1 > /proc/sys/net/ipv4/ip_forward 
echo "mknod /dev/ppp c 108 0" >> /etc/rc.local
echo "echo 1 > /proc/sys/net/ipv4/ip_forward" >> /etc/rc.local
echo "localip 172.16.36.1" >> /etc/pptpd.conf
echo "remoteip 172.16.36.2-254" >> /etc/pptpd.conf
echo "ms-dns 8.8.8.8" >> /etc/ppp/options.pptpd
echo "ms-dns 8.8.4.4" >> /etc/ppp/options.pptpd

pass=`openssl rand 6 -base64`
if [ "$1" != "" ]
then pass=$1
fi

echo "vpn pptpd ${pass} *" >> /etc/ppp/chap-secrets

iptables -t nat -A POSTROUTING -s 172.16.36.0/24 -j SNAT --to-source 116.251.217.106 | cut -d: -f2 | awk 'NR==1 { print $1}'`
iptables -A FORWARD -p tcp --syn -s 172.16.36.0/24 -j TCPMSS --set-mss 1356
service iptables save

chkconfig iptables on
chkconfig pptpd on

service iptables start
service pptpd start

echo "VPN service is installed, your VPN username is vpn, VPN password is ${pass}"
