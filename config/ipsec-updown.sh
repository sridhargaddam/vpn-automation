#!/bin/bash

# Reference:
# https://wiki.strongswan.org/projects/strongswan/wiki/RouteBasedVPN
# https://gist.github.com/heri16/2f59d22d1d5980796bfb

IP=$(which ip)
IPTABLES=$(which iptables)

PLUTO_MARK_OUT_ARR=(${PLUTO_MARK_OUT//// })
PLUTO_MARK_IN_ARR=(${PLUTO_MARK_IN//// })
case "$PLUTO_CONNECTION" in
  AWS-VPC-GW1)
    VTI_INTERFACE=vti1
    VTI_LOCALADDR=169.254.57.202/30
    VTI_REMOTEADDR=169.254.57.201/30
    ;;
  AWS-VPC-GW2)
    VTI_INTERFACE=vti2
    VTI_LOCALADDR=169.254.59.114/30
    VTI_REMOTEADDR=169.254.59.113/30
    ;;
esac

case "${PLUTO_VERB}" in
    up-client)
        $IP link add ${VTI_INTERFACE} type vti local ${PLUTO_ME} remote ${PLUTO_PEER} okey ${PLUTO_MARK_OUT_ARR[0]} ikey ${PLUTO_MARK_IN_ARR[0]}
        sysctl -w net.ipv4.conf.${VTI_INTERFACE}.disable_policy=1
        sysctl -w net.ipv4.conf.${VTI_INTERFACE}.rp_filter=0
        $IP addr add ${VTI_LOCALADDR} remote ${VTI_REMOTEADDR} dev ${VTI_INTERFACE}
        $IP link set ${VTI_INTERFACE} up mtu 1419
        $IPTABLES -t mangle -I FORWARD -o ${VTI_INTERFACE} -p tcp -m tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
        $IPTABLES -t mangle -I INPUT -p esp -s ${PLUTO_PEER} -d ${PLUTO_ME} -j MARK --set-xmark ${PLUTO_MARK_IN}
        $IP route flush table 220
        $IP route add 10.20.20.0/24 dev ${VTI_INTERFACE}
        ;;
    down-client)
        $IP link del ${VTI_INTERFACE}
        $IPTABLES -t mangle -D FORWARD -o ${VTI_INTERFACE} -p tcp -m tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
        $IPTABLES -t mangle -D INPUT -p esp -s ${PLUTO_PEER} -d ${PLUTO_ME} -j MARK --set-xmark ${PLUTO_MARK_IN}
        ;;
esac
