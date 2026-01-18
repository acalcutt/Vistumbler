---
title: 'Hurricane Electric IPv6 tunnel - Server 2012'
date: '04-04-2023 10:57'
visible: true
---

<span class="visualHighlight">netsh interface ipv6 add v6v4tunnel HEipv6tunnel \[</span><span class="helpBubble" title="td4">Client IPv4 Address</span><span class="visualHighlight">\] \[</span><span class="helpBubble" title="td2">Server IPv4 Address</span><span class="visualHighlight">\]  
netsh interface ipv6 add address HEipv6tunnel</span><span class="visualHighlight"> \[Client IPv6 Address\]</span><span class="visualHighlight">  
netsh interface ipv6 add route ::/0 HEipv6tunnel \[</span><span class="helpBubble" title="td2">Server IPv4 Address</span><span class="visualHighlight">\]</span><span class="visualHighlight">  
netsh interface ipv6 add route \[</span><span class="helpBubble" title="td7">Routed /64\]</span><span class="visualHighlight"> interface="Ethernet" publish=yes store=persistent  
netsh interface ipv6 set interface HEipv6tunnel forwarding=enabled  
netsh interface ipv6 set interface Ethernet forwarding=enabled advertise=enabled advertisedefaultroute=enabled store=persistent managed=enabled  
</span>

\---------------------------------------------------------------------------------------------------------------------------  
Example  
\---------------------------------------------------------------------------------------------------------------------------

**Server IPv4 Address:** 209.x.x.x  
**Server IPv6 Address:** 2001:x:1:x::1/64  
**Client IPv4 Address:** 68.x.x.x (this should be the external IP you gave hurricane electric unless you are behind a nat. If you are behind a nat use your local ip (ex 192.x.x.x))  
**Client IPv6 Address:** 2001:x:1:x::2/64  
**Routed /64:** 2001:x:2:x::/64

<span class="visualHighlight">netsh interface ipv6 add v6v4tunnel HEipv6tunnel </span>68.x.x.x<span class="visualHighlight"> </span>209.x.x.x<span class="visualHighlight">  
netsh interface ipv6 add address HEipv6tunnel </span>2001:x:1:x::2/64<span class="visualHighlight">  
netsh interface ipv6 add route ::/0 HEipv6tunnel </span>2001:x:1:x::1<span class="visualHighlight">  
netsh interface ipv6 add route </span>2001:x:2:x::/64<span class="visualHighlight"> interface="Ethernet" publish=yes store=persistent  
netsh interface ipv6 set interface HEipv6tunnel forwarding=enabled  
netsh interface ipv6 set interface Ethernet forwarding=enabled advertise=enabled advertisedefaultroute=enabled store=persistent managed=enabled  
</span>