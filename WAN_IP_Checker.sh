#!/bin/bash

#---------------------------------------------------------------------
# WAN IP CÍM LEKÉRDEZŐ / ELLENŐRZŐ SCRIPT / DYN DNS FRISSÍTŐ
# EZZEL A SCRIPTTEL 4 KÜLÖNBÖZŐ SZOLGÁLTATÓVAL KÉRDEZHETJÜK LE
# A PUBLIKUS (WAN) IP CÍMÜNKET. AZ ELSŐ VALID IP CÍM LEKÉRDEZÉS UTÁN
# A SCRIPT TOVÁBBLÉP, NEM ELLENŐRZI VÉGIG MIND A 4 IP CÍM API-T.
# A 4 IP API A REDUNDANCIA MIATT VAN A PROGRAMBAN.
#
# AMENNYIBEN MEGVÁLTOZOTT A WAN IP CÍMÜNK A KORÁBBAN MENTETTHEZ
# KÉPEST, AKKOR KÜLÖNBÖZŐ MŰVELETEKET HAJTHATUNK VÉGRE, PL.
# DINAMIKUS DNS SZOLGÁLATATÓNAL HASZNALT DOMAIN NÉV / IP CÍM
# FRISSÍTÉST, SZOLGÁLTATÁSOK ÚJRAINDÍTÁSÁT, ÉRTESÍTÉST STB.
#
# A SCRIPT AZ IPv4 ÉS IPv6 VERZIÓKKAL IS MŰKÖDIK!
#
# A SCRIPT NAPLÓZZA MŰKÖDÉSÉT
#
# TESZTELVE: Oracle Linux 9.2 / CentOS 7.9
#
# A SCRIPTET ÍRTA: C2H5Cl, Aethyl-chloride, 2019
# FRISSÍTVE: 2023-06-17
#---------------------------------------------------------------------


#---------------------------------------------------------------------
# BEÁLLÍTÁSOK
#---------------------------------------------------------------------

#---------------------------------------------------------------------
#- WAN IP TEXT FÁJL ABSOLUTE PATH
#---------------------------------------------------------------------

IP_ADDR_FAJL="/var/log/wanipaddress.txt"

#---------------------------------------------------------------------
#- DÁTUMOK + LOG FÁJL DIR + FÁJL
#---------------------------------------------------------------------

DATUM=$(date +"%Y-%m-%d")
LOGDATUM=$(date +"%Y-%m-%d")
FULLDATUM=$(date +"%Y-%m-%d %H-%M-%S")

LOGFAJL_DIR="/var/log/WANIPChange"
LOGFAJL="$LOGFAJL_DIR/$LOGDATUM.txt"

#---------------------------------------------------------------------
#- IP API URL CÍMEK + BARÁTSÁGOS NEVEK
#---------------------------------------------------------------------

UPD_URL[1]="https://api.ipify.org"
UPD_URL_NAME[1]="IPIFY.ORG"

UPD_URL[2]="http://api.ipaddress.com/myip"
UPD_URL_NAME[2]="IPADDRESS.COM"

UPD_URL[3]="https://ipecho.net/plain"
UPD_URL_NAME[3]="IPECHO.NET"

UPD_URL[4]="https://api.seeip.org/"
UPD_URL_NAME[4]="SEEIP.ORG"

#---------------------------------------------------------------------
#- LEGYEN WAN IP VÁLTOZÁSKOR DYN DNS FRISSITES (igen / nem)
#---------------------------------------------------------------------

DYN_UPDATE="igen"

#---------------------------------------------------------------------
#- DYN DNS USER / UPDATE KEY
#---------------------------------------------------------------------

DYN_UN="userName"
DYN_UPD_KEY="0123456789abcdef0123456789abcde"

#---------------------------------------------------------------------
#- DYN DNS FRISSÍTENDŐ DOMAIN NEVEK
#---------------------------------------------------------------------

DYN_DOMAIN[1]="domain1.dyndns.com"
DYN_DOMAIN[2]="domain2.dyndns.com"
DYN_DOMAIN[3]="domain3.dyndns.com"
DYN_DOMAIN[4]="domain4.dyndns.com"
DYN_DOMAIN[5]=""
DYN_DOMAIN[6]=""
DYN_DOMAIN[7]=""
DYN_DOMAIN[8]=""
DYN_DOMAIN[9]=""

#---------------------------------------------------------------------
#- EGYÉB VÁLTOZÓK
#---------------------------------------------------------------------

WANIPCIM="x"
MENTETTWANIP="x"
IPCIMTXT="x"
FRISSITSUNK="x"
UPDSVC="x"

#---------------------------------------------------------------------
#- LOG DIR LÉTREHOZÁSA, HA NEM LÉTEZIK
#---------------------------------------------------------------------

if [ ! -d "$LOGFAJL_DIR" ] ; then
	mkdir -p $LOGFAJL_DIR
	sleep 1
fi

#---------------------------------------------------------------------
#- START WAN IP CHECK + UPDATE
#---------------------------------------------------------------------

echo "$FULLDATUM - IP CHECK ELINDULT..."
echo "$FULLDATUM - IP CHECK ELINDULT..." >> $LOGFAJL

#---------------------------------------------------------------------
# CIKLUSSAL MEGYÜNK VÉGIG A FRISSÍTÉSI SZOLGÁLTATÓKON
# AMINT SIKERESEN LEKÉRDEZZÜK A WAN IP CÍMET, KILÉPÜNK A CIKLUSBÓL
# HA NEM SIKERÜL LEKÉRDEZNI A WAN IP CÍMET A 4 SZOLGÁLTATÓ EGYIKÉVEL SEM,
# ARRÓL ÜZENETET KÜLDÜNK ÉS NAPLÓZZUK IS
#---------------------------------------------------------------------

for i in 1 2 3 4

	do

	if [ ! -z "${UPD_URL[$i]}" ] ; then

		echo "$FULLDATUM - ${UPD_URL[$i]} - WAN IP LEKERDEZESE..."
		echo "$FULLDATUM - ${UPD_URL[$i]} - WAN IP LEKERDEZESE..." >> $LOGFAJL
		WANIPCIM=$(curl "${UPD_URL[$i]}" --connect-timeout 20 -k -s)

		if [ ! -z "${UPD_URL_NAME[$i]}" ] ; then
			UPDSVC=${UPD_URL_NAME[$i]}
		else
			UPDSVC="---"
		fi

		FULLDATUM=$(date +"%Y-%m-%d %H-%M-%S")

		#---------------------------------------------------------------------

		if [[ "$WANIPCIM" =~ ^(([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))\.){3}([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))$ ]] || [[ $WANIPCIM =~ ([0-9a-fA-F]{0,4}:){1,7}[0-9a-fA-F]{0,4}$ ]] ; then

			# Okay - valid IP cím
			echo "$FULLDATUM - ${UPD_URL[$i]} - VALID IP CIM: $WANIPCIM"
			echo "$FULLDATUM - ${UPD_URL[$i]} - VALID IP CIM: $WANIPCIM" >> $LOGFAJL

			break

		else

			# Nem Okay - nem valid az IP cím
			echo "$FULLDATUM - ${UPD_URL[$i]} - NEM VALID IP CIM: $WANIPCIM"
			echo "$FULLDATUM - ${UPD_URL[$i]} - NEM VALID IP CIM: $WANIPCIM" >> $LOGFAJL

			WANIPCIM="x"

		fi
	    
	fi

done

#---------------------------------------------------------------------
# NEM SIKERÜLT A WAN IP LEKÉRDEZÉSE - NAPLÓZUNK, MAJD KILÉPÜNK
#---------------------------------------------------------------------

if [ -z "$WANIPCIM" ] || [ $WANIPCIM == "x" ] ; then

	if [ -f "$IP_ADDR_FAJL" ] ; then

		#---------------------------------------------------------------------
		# Van ipcim.txt fájl, beszívjuk a tartalmát
		#---------------------------------------------------------------------

		MENTETTWANIP=$(head -n 1 $IP_ADDR_FAJL)

    else

		#---------------------------------------------------------------------
		# Nincs ipcim.txt fájl
		#---------------------------------------------------------------------

		MENTETTWANIP="NINCS IPCIM.TXT FAJL"

    fi

	#---------------------------------------------------------------------

	WANIPCIM="0.0.0.0"
	UPDSVC="SIKERTELEN"
	FULLDATUM=$(date +"%Y-%m-%d %H-%M-%S")

	echo "$FULLDATUM - NEM SIKERULT A WAN IP LEKERDEZESE (NETWORK?)" >> $LOGFAJL
	echo "$FULLDATUM - UTOLSO MENTETT WAN IP: $MENTETTWANIP" >> $LOGFAJL
	echo "$FULLDATUM - AKTUALIS WAN IP: $WANIPCIM" >> $LOGFAJL
	echo "$FULLDATUM - FRISSITESI SZOLGALTATO: $UPDSVC" >> $LOGFAJL
	echo "====================================================================================" >> $LOGFAJL
	echo "$FULLDATUM - NEM SIKERULT A WAN IP LEKERDEZES (NETWORK?)"

	exit 0;

fi


#---------------------------------------------------------------------
# Megnezzük, van-e ipcim.txt fájl a megadott mappában
#---------------------------------------------------------------------

if [ -f "$IP_ADDR_FAJL" ] ; then

	#---------------------------------------------------------------------
	# Van ipcim.txt fájl, beszívjuk a tartalmát
	#---------------------------------------------------------------------

	FULLDATUM=$(date +"%Y-%m-%d %H-%M-%S")
	IPCIMTXT="Ok"

	echo "$FULLDATUM - VAN IP CIM FAJL..."
	MENTETTWANIP=$(head -n 1 $IP_ADDR_FAJL)
	echo "$FULLDATUM - JELENLEGI WAN IP CIM: $WANIPCIM"
	echo "$FULLDATUM - KORABBI WAN IP CIM: $MENTETTWANIP"
	echo "$FULLDATUM - IP CIM TXT $IP_ADDR_FAJL LETEZIK" >> $LOGFAJL

else

	#---------------------------------------------------------------------
	# Nincs ipcim.txt fájl, létrehozzuk + beírjuk az aktuális WAN IP-t
	#---------------------------------------------------------------------

	FULLDATUM=$(date +"%Y-%m-%d %H-%M-%S")
	IPCIMTXT="nOk"
	MENTETTWANIP="0.0.0.0"

	echo "0.0.0.0">$IP_ADDR_FAJL
	echo "$FULLDATUM - NINCS IP CIM FAJL..."
	echo "$FULLDATUM - A $IP_ADDR_FAJL LETREHOZVA! (0.0.0.0)"
	echo "$FULLDATUM - JELENLEGI IP CIM: $WANIPCIM"
	echo "$FULLDATUM - NINCS IP CIM TXT - LETREHOZVA" >> $LOGFAJL

fi

#---------------------------------------------------------------------
# Ellenőrizzük, hogy a mentett WAN IP egyezik-e a jelenlegivel
#---------------------------------------------------------------------

if [ $WANIPCIM == $MENTETTWANIP ] ; then

	FULLDATUM=$(date +"%Y-%m-%d %H-%M-%S")
	FRISSITSUNK="no"
	echo "$FULLDATUM - WAN IP NEM VALTOZOTT"

else

	FULLDATUM=$(date +"%Y-%m-%d %H-%M-%S")
	FRISSITSUNK="yes"
	echo ${WANIPCIM}>$IP_ADDR_FAJL
	echo "$FULLDATUM - WAN IP VALTOZOTT"

fi

#---------------------------------------------------------------------
# Ha a korábbi WAN IP nem egyezik a most lekérdezettel, vagy
# nem létezett a WAN IP címet tartalmazó fájl, akkor az alábbi
# műveleteket hajtjuk végre.
# Ezek lehetnek szolgáltatás újraindítások, dinamikus DNS rekordok
# frissítései, bármi egyéb, az alábbiak csak példák
#---------------------------------------------------------------------

if [ $FRISSITSUNK == "yes" ] || [ $IPCIMTXT == "nOk" ] ; then

	if [ $DYN_UPDATE == "igen" ] ; then

		#---------------------------------------------------------------------
		# DynDNS FRISSÍTÉS (MAX. 9) - TIMEOUT 15 SEC / DOMAIN
		#---------------------------------------------------------------------
		# CIKLUSSAL MEGYÜNK VÉGIG A FRISSÍTENDŐ DOMAIN NEVEKEN
		#---------------------------------------------------------------------

		for i in 1 2 3 4 5 6 7 8 9

			do

				if [ ! -z "${DYN_DOMAIN[$i]}" ] ; then

					FULLDATUM=$(date +"%Y-%m-%d_%H-%M-%S")

					echo "$FULLDATUM - ${DYN_DOMAIN[$i]} FRISSITESE..."
					echo "$FULLDATUM - ${DYN_DOMAIN[$i]} FRISSITESE..." >> $LOGFAJL
					
					# Demo
					echo "https://$DYN_UN:$DYN_UPD_KEY@members.dyndns.org/v3/update?hostname=${DYN_DOMAIN[$i]}&myip=${WANIPCIM} --connect-timeout 15 -k -s"

					# DynDNS UPDATE
					#curl "https://$DYN_UN:$DYN_UPD_KEY@members.dyndns.org/v3/update?hostname=${DYN_DOMAIN[$i]}&myip=${WANIPCIM}" --connect-timeout 15 -k -s

				fi

			done

		#---------------------------------------------------------------------
		# NAPLÓZÁS
		#---------------------------------------------------------------------

		FULLDATUM=$(date +"%Y-%m-%d_%H-%M-%S")

		echo "$FULLDATUM - ORACLE / DynDNS FRISSITESEK BEFEJEZVE... SERVICEK UJRAINNDITASA..."
		echo "$FULLDATUM - ORACLE / DynDNS FRISSITESEK BEFEJEZVE..." >> $LOGFAJL
		echo "$FULLDATUM - SERVICEK UJRAINDITASA..." >> $LOGFAJL

		#---------------------------------------------------------------------

	else

		echo "$FULLDATUM - DYN DNS FRISSITES KIKAPCSOLVA..."
		echo "$FULLDATUM - DYN DNS FRISSITES KIKAPCSOLVA..." >> $LOGFAJL

	fi

	#---------------------------------------------------------------------
	# VSFTPD SERVICE LEÁLLÍTÁSA
	#---------------------------------------------------------------------

	FULLDATUM=$(date +"%Y-%m-%d %H-%M-%S")
	echo "$FULLDATUM - VSFTPD LEALLITASA..."
	# systemctl stop vsftpd.service
	sleep 2

	#---------------------------------------------------------------------
	# NGINX SERVICE LEÁLLÍTÁSA
	#---------------------------------------------------------------------

	# FULLDATUM=$(date +"%Y-%m-%d %H-%M-%S")
	# echo "$FULLDATUM - NGINX LEALLITASA..."
	# systemctl stop nginx.service
	# sleep 2

	#---------------------------------------------------------------------
	# PHP-FPM SERVICE LEÁLLÍTÁSA
	#---------------------------------------------------------------------

	# FULLDATUM=$(date +"%Y-%m-%d %H-%M-%S")
	# echo "$FULLDATUM - PHP72-FPM LEALLITASA..."
	# systemctl stop php72-php-fpm.service
	# sleep 2


	#---------------------------------------------------------------------
	# NAPLÓZÁS
	#---------------------------------------------------------------------

	FULLDATUM=$(date +"%Y-%m-%d %H-%M-%S")
	echo "$FULLDATUM - SERVICEK LEALLITVA... WAN IP VALTOZOTT" >> $LOGFAJL

	#---------------------------------------------------------------------
	# PHP-FPM SERVICE INDÍTÁSA
	#---------------------------------------------------------------------

	# FULLDATUM=$(date +"%Y-%m-%d %H-%M-%S")
	# echo "$FULLDATUM - PHP72-FPM INDITASA..."
	# systemctl start php72-php-fpm.service
	# sleep 2

	#---------------------------------------------------------------------
	# NGINX SERVICE INDÍTÁSA
	#---------------------------------------------------------------------

	# FULLDATUM=$(date +"%Y-%m-%d %H-%M-%S")
	# echo "$FULLDATUM - NGINX INDITASA..."
	# systemctl start nginx.service
	# sleep 2

	#---------------------------------------------------------------------
	# VSFTPD SERVICE INDÍTÁSA
	#---------------------------------------------------------------------

	FULLDATUM=$(date +"%Y-%m-%d %H-%M-%S")
	echo "$FULLDATUM - VSFTPD INDITASA..."
	# systemctl start vsftpd.service
	sleep 2

	#---------------------------------------------------------------------
	# NAPLÓZÁS
	#---------------------------------------------------------------------

	FULLDATUM=$(date +"%Y-%m-%d %H-%M-%S")
	echo "$FULLDATUM - FRISSITES KESZ... ($UPDSVC)"
	echo "$FULLDATUM - SERVICEK UJRAINDITVA... WAN IP VALTOZOTT" >> $LOGFAJL
	echo "$FULLDATUM - ELOZO WAN IP: $MENTETTWANIP" >> $LOGFAJL
	echo "$FULLDATUM - AKTUALIS WAN IP: $WANIPCIM" >> $LOGFAJL
	echo "$FULLDATUM - FRISSITESI SZOLGALTATAS: $UPDSVC" >> $LOGFAJL
	echo "====================================================================================" >> $LOGFAJL
	sleep 2

else

	#---------------------------------------------------------------------
	# NAPLÓZÁS
	#---------------------------------------------------------------------

	FULLDATUM=$(date +"%Y-%m-%d %H-%M-%S")
	echo "$FULLDATUM - NINCS SZUKSEG FRISSITESRE... ($UPDSVC)"
	echo "$FULLDATUM - NINCS SZUKSEG FRISSITESRE" >> $LOGFAJL
	echo "$FULLDATUM - ELOZO WAN IP: $MENTETTWANIP" >> $LOGFAJL
	echo "$FULLDATUM - AKTUALIS WAN IP: $WANIPCIM" >> $LOGFAJL
	echo "$FULLDATUM - FRISSITESI SZOLGALTATAS: $UPDSVC" >> $LOGFAJL
	echo "====================================================================================" >> $LOGFAJL
	sleep 2

fi

#---------------------------------------------------------------------

exit 0;
