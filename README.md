## WAN IP CHECKER + DYN DNS UPDATER (IPv4 + IPv6)

Ezzel a scripttel a publikus (WAN) IP címunket kérdezhetjük le tetszőleges számú szolgáltatótól. A script a lekérdezést követően összehasonlítja a lekérdezés eredményét a korábban fájlba mentett IP címmel.

Amennyiben a mentett IP címhez képest megváltozott a publikus IP címünk, abban az esetben különböző műveleteket hajthatunk végre, igény szerint.

Ezek a műveletek lehetnek dinamikus domain név frissítések, szolgáltatás újraindítások, jelentések stb. 

A script az **${\color{yellow}IPv4}$** és **${\color{yellow}IPv6}$** címeket is kezeli és a **${\color{yellow}dyn.com}$** valamint a **${\color{yellow}no&#8208;ip.com}$** szolgáltatókkal működik.

A script beállításaiban korlátlan számú publikus IP API szolgáltatót lehet beállítani a redundancia miatt. Az első valid IP címet visszaadó lekérdezést követően a script továbblép, nem ellenőrzi le az összes beállított szolgáltatótól a WAN IP címünket.


**Példa egy új IP API szolgáltató felvételére:**

```

UPD_URL[5]="https://api.peldaip.org.hu/"
UPD_URL_NAME[5]="PELDAIP.ORG.HU"

UPD_URL[...]="https://api.ex.org.hu/"
UPD_URL_NAME[...]="EX.ORG.HU"

UPD_URL[10]="https://api.iphuex15.org.hu/"
UPD_URL_NAME[10]="IPHUEX15.ORG.HU"

stb.
```

A script beállításaiban korlátlan számú frissítendő dinamikus domain nevet lehet beállítani.


**Példa egy új dinamikus domain felvételére:**

```

DYN_DOMAIN[4]="pelda.dyndns.com"

DYN_DOMAIN[...]="xxx.dyndns.com"

DYN_DOMAIN[15]="domain15.dyndns.com"

stb.
```

**TESZTELVE:**

* Oracle Linux 9.2
* CentOS 7.9


#### Konzol kimenet

```

2023-06-17 22-51-00 - IP CHECK ELINDULT...
2023-06-17 22-51-00 - https://api.ipify.org - WAN IP LEKERDEZESE...
2023-06-17 22-51-01 - https://api.ipify.org - VALID IP CIM: 80.10.20.30
2023-06-17 22-51-01 - IP CIM TXT FAJL /var/log/wanipaddress.txt LETEZIK...
2023-06-17 22-51-01 - JELENLEGI WAN IP CIM: 80.10.20.30
2023-06-17 22-51-01 - KORABBI WAN IP CIM: 2001:0Db8:85a3:0000:0000:8a2e:0370:7334
2023-06-17 22-51-01 - WAN IP VALTOZOTT
2023-06-17 22-51-01 - DINAMIKUS IP SZOLGALTATO: dyn.com
2023-06-17_22-51-01 - domain1.dyndns.com FRISSITESE...
2023-06-17_22-51-01 - https://userName:1234567890abcdef1234567890abcde@members.dyndns.org/v3/update?hostname=domain1.dyndns.com&myip=80.10.20.30 --user-agent bash-curl-cron/1.0 anonymous@mail.wxyz --connect-timeout 15 -k -s
2023-06-17_22-51-09 - domain2.dyndns.com FRISSITESE...
2023-06-17_22-51-09 - https://userName:1234567890abcdef1234567890abcde@members.dyndns.org/v3/update?hostname=domain2.dyndns.com&myip=80.10.20.30 --user-agent bash-curl-cron/1.0 anonymous@mail.wxyz --connect-timeout 15 -k -s
2023-06-17_22-51-14 - domain3.dyndns.com FRISSITESE...
2023-06-17_22-51-14 - https://userName:1234567890abcdef1234567890abcde@members.dyndns.org/v3/update?hostname=domain3.dyndns.com&myip=80.10.20.30 --user-agent bash-curl-cron/1.0 anonymous@mail.wxyz --connect-timeout 15 -k -s
2023-06-17_22-51-17 - DynDNS FRISSITESEK BEFEJEZVE... SERVICEK UJRAINDITASA...
2023-06-17 22-51-17 - VSFTPD LEALLITASA...
2023-06-17 22-51-19 - VSFTPD INDITASA...
2023-06-17 22-51-21 - FRISSITES KESZ... (IPIFY.ORG)

```

### Log fájl kimenet

```

2023-06-17 22-51-00 - IP CHECK ELINDULT...
2023-06-17 22-51-00 - https://api.ipify.org - WAN IP LEKERDEZESE...
2023-06-17 22-51-01 - https://api.ipify.org - VALID IP CIM: 80.10.20.30
2023-06-17 22-51-01 - IP CIM TXT FAJL /var/log/wanipaddress.txt LETEZIK
2023-06-17 22-51-01 - DINAMIKUS IP SZOLGALTATO: dyn.com
2023-06-17_22-51-01 - domain1.dyndns.com FRISSITESE...
2023-06-17_22-51-09 - domain2.dyndns.com FRISSITESE...
2023-06-17_22-51-14 - domain3.dyndns.com FRISSITESE...
2023-06-17_22-51-17 - DynDNS FRISSITESEK BEFEJEZVE...
2023-06-17_22-51-17 - SERVICEK UJRAINDITASA...
2023-06-17 22-51-19 - SERVICEK LEALLITVA... WAN IP VALTOZOTT
2023-06-17 22-51-21 - SERVICEK UJRAINDITVA... WAN IP VALTOZOTT
2023-06-17 22-51-21 - ELOZO WAN IP: 2001:0Db8:85a3:0000:0000:8a2e:0370:7334
2023-06-17 22-51-21 - AKTUALIS WAN IP: 80.10.20.30
2023-06-17 22-51-21 - FRISSITESI SZOLGALTATAS: IPIFY.ORG

```

