# WAN IP CHECKER + DYN DNS UPDATER (IPv4 + IPv6)

Ezzel a scripttel a publikus (WAN) IP címunket kérdezhetjük le tetszőleges számú szolgáltatótól. A script a lekérdezést követően összehasonlítja a lekérdezés eredményét a korábban fájlba mentett IP címmel.

Amennyiben a mentett IP címhez képest megváltozott a publikus IP címünk, abban az esetben különböző műveleteket hajthatunk végre, igény szerint.

Ezek a műveletek lehetnek dinamikus domain név frissítések, szolgáltatás újraindítások, jelentések stb.

A script beállításaiban korlátlan számú publikus IP API szolgáltatót lehet beállítani a redundancia miatt. Az első valid IP címet visszaadó lekérdezést követően a scrript továbblép, nem ellenőrzi le az összes beállított szolgáltatótól a WAN IP címünket.


Pl.:

```
UPD_URL[5]="https://pelda.org.hu/"
UPD_URL_NAME[5]="PELDA.ORG.HU"
```

A script beállításaiben korlátlan számú dinamikus domain nevet lehet beállítani.


Pl.:

```
DYN_DOMAIN[4]="pelda.dyndns.com"
```


### A script az IPv4 és IPv6 címeket is kezeli.


### Konzol kimenet

```

2023-06-17 19-20-50 - IP CHECK ELINDULT...
2023-06-17 19-20-50 - https://api.ipify.org - WAN IP LEKERDEZESE...
2023-06-17 19-20-53 - https://api.ipify.org - VALID IP CIM: 80.10.20.30
2023-06-17 19-20-53 - IP CIM TXT FAJL /var/log/wanipaddress.txt LETEZIK...
2023-06-17 19-20-53 - JELENLEGI WAN IP CIM: 80.10.20.30
2023-06-17 19-20-53 - KORABBI WAN IP CIM: 2001:0Db8:85a3:0000:0000:8a2e:0370:7334
2023-06-17 19-20-53 - WAN IP VALTOZOTT
2023-06-17_19-20-53 - domain1.dyndns.com FRISSITESE...
2023-06-17_19-20-53 - https://userName:0123456789abcdef0123456789abcde@members.dyndns.org/v3/update?hostname=domain1.dyndns.com&myip=80.10.20.30 --connect-timeout 15 -k -s
2023-06-17_19-20-53 - domain2.dyndns.com FRISSITESE...
2023-06-17_19-20-53 - https://userName:0123456789abcdef0123456789abcde@members.dyndns.org/v3/update?hostname=domain2.dyndns.com&myip=80.10.20.30 --connect-timeout 15 -k -s
2023-06-17_19-20-53 - domain3.dyndns.com FRISSITESE...
2023-06-17_19-20-53 - https://userName:0123456789abcdef0123456789abcde@members.dyndns.org/v3/update?hostname=domain3.dyndns.com&myip=80.10.20.30 --connect-timeout 15 -k -s
2023-06-17_19-20-53 - domain4.dyndns.com FRISSITESE...
2023-06-17_19-20-53 - https://userName:0123456789abcdef0123456789abcde@members.dyndns.org/v3/update?hostname=domain4.dyndns.com&myip=80.10.20.30 --connect-timeout 15 -k -s
2023-06-17_19-20-53 - DynDNS FRISSITESEK BEFEJEZVE... SERVICEK UJRAINNDITASA...
2023-06-17 19-20-53 - VSFTPD LEALLITASA...
2023-06-17 19-20-55 - VSFTPD INDITASA...
2023-06-17 19-20-57 - FRISSITES KESZ... (IPIFY.ORG)

```

### Log fájl kimenet

```

2023-06-17 19-20-50 - IP CHECK ELINDULT...
2023-06-17 19-20-50 - https://api.ipify.org - WAN IP LEKERDEZESE...
2023-06-17 19-20-53 - https://api.ipify.org - VALID IP CIM: 80.10.20.30
2023-06-17 19-20-53 - IP CIM TXT FAJL /var/log/wanipaddress.txt LETEZIK
2023-06-17_19-20-53 - domain1.dyndns.com FRISSITESE...
2023-06-17_19-20-53 - domain2.dyndns.com FRISSITESE...
2023-06-17_19-20-53 - domain3.dyndns.com FRISSITESE...
2023-06-17_19-20-53 - domain4.dyndns.com FRISSITESE...
2023-06-17_19-20-53 - DynDNS FRISSITESEK BEFEJEZVE...
2023-06-17_19-20-53 - SERVICEK UJRAINDITASA...
2023-06-17 19-20-55 - SERVICEK LEALLITVA... WAN IP VALTOZOTT
2023-06-17 19-20-57 - SERVICEK UJRAINDITVA... WAN IP VALTOZOTT
2023-06-17 19-20-57 - ELOZO WAN IP: 2001:0Db8:85a3:0000:0000:8a2e:0370:7334
2023-06-17 19-20-57 - AKTUALIS WAN IP: 80.10.20.30
2023-06-17 19-20-57 - FRISSITESI SZOLGALTATAS: IPIFY.ORG

```
