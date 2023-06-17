# WAN IP CHECKER + DYN DNS UPDATER (IPv4 + IPv6)

Ezzel a scripttel a publikus (WAN) IP címunket kérdezhetjük le és hasonlíthatjuk össze a korábban mentett címmel Linux rendszereken, és frissíthejük a dinamikus domain nevünket. (9 db)

Amennyiben a mentett IP címhez képest megváltozott a publikus IP címünk, abban az esetben különböző műveleteket hajthatunk végre, igény szerint.

Ezek a műveletek lehetnek dinamikus domain név frissítések, szolgáltatás újraindítások, jelentések stb.

A script beállításaiban 4 db publikus IP API szolgáltatót lehet beállítani a redundancia miatt. Az első valid IP címet visszaadó lekérdezést követően a scrript továbblép, nem ellenőrzi le mind a 4 szolgáltatótól a WAN IP címünket.

A script az IPv4 és IPv6 címeket is kezeli.

Konzol kimenet

```
2023-06-17 17-45-46 - IP CHECK ELINDULT...
2023-06-17 17-45-46 - https://api.ipify.org - WAN IP LEKERDEZESE...
2023-06-17 17-46-06 - https://api.ipify.org - NEM VALID IP CIM
2023-06-17 17-46-06 - http://api.ipaddress.com/myip - WAN IP LEKERDEZESE...
2023-06-17 17-46-06 - http://api.ipaddress.com/myip - VALID IP CIM: 80.10.20.30
2023-06-17 17-46-06 - VAN IP CIM FAJL...
2023-06-17 17-46-06 - JELENLEGI WAN IP CIM: 80.10.20.30
2023-06-17 17-46-06 - KORABBI WAN IP CIM: 80.10.20.30
2023-06-17 17-46-07 - WAN IP NEM VALTOZOTT
2023-06-17 17-46-08 - NINCS SZUKSEG FRISSITESRE... (IPADDRESS.COM)
```

Logfájl kimenet

```
2023-06-17 17-45-46 - IP CHECK ELINDULT...
2023-06-17 17-45-46 - https://api.ipify.org - WAN IP LEKERDEZESE...
2023-06-17 17-46-06 - https://api.ipify.org - NEM VALID IP CIM
2023-06-17 17-46-06 - http://api.ipaddress.com/myip - WAN IP LEKERDEZESE...
2023-06-17 17-46-06 - http://api.ipaddress.com/myip - VALID IP CIM: 80.10.20.30
2023-06-17 17-46-06 - IP CIM TXT /var/log/wanipaddress.txt LETEZIK
2023-06-17 17-46-08 - NINCS SZUKSEG FRISSITESRE
2023-06-17 17-46-08 - ELOZO WAN IP: 80.10.20.30
2023-06-17 17-46-08 - AKTUALIS WAN IP: 80.10.20.30
2023-06-17 17-46-08 - FRISSITESI SZOLGALTATAS: IPADDRESS.COM
```
