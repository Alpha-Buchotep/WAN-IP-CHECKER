# WAN-IP CHECKER

Ezzel a scripttel a publikus (WAN) IP címunket kérdezhetjük le.
Amennyiben a mentett IP címhez képest megváltozott a publikus IP címünk, abban az esetben különböző műveleteket hajthatunk végre, igény szerint.

Ezek a múveletek lehetnek dinamikus domain név frissítések, szolgáltatás újraindítások, jelentések stb.

A script beállításaiban 4 db publikus IP API szolgáltatót lehet beállítani a redundancia miatt. Az első valid IP címet visszaadó lekérdezést követően a scrript továbblép, nem ellenőrzi le mind a 4 szolgáltatótól az WAN IP címünket.
