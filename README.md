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

...

UPD_URL[10]="https://api.iphuex15.org.hu/"
UPD_URL_NAME[10]="IPHUEX15.ORG.HU"

stb.
```

A script beállításaiban maximum 20 db frissítendő dinamikus domain nevet lehet beállítani.


**Példa egy új dinamikus domain felvételére:**

```

DYN_DOMAIN[4]="pelda.dyndns.com"

...

DYN_DOMAIN[15]="domain15.dyndns.com"

stb.
```

**TESZTELVE:**

* Oracle Linux 9.2 x64
* CentOS Linux 7.9.2009 x64


