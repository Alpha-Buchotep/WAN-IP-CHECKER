#!/bin/bash

#---------------------------------------------------------------------
# WAN IP CÍM LEKÉRDEZŐ / ELLENŐRZŐ SCRIPT / DYN DNS FRISSÍTŐ
# EZZEL A SCRIPTTEL TETSZŐLEGES SZÁMÚ SZOLGÁLTATÓTÓL KÉRDEZHETJÜK LE
# A PUBLIKUS (WAN) IP CÍMÜNKET. AZ ELSŐ VALID IP CÍM LEKÉRDEZÉS UTÁN
# A SCRIPT TOVÁBBLÉP, NEM ELLENŐRZI VÉGIG AZ ÖSSZES IP CÍM API-T.
#---------------------------------------------------------------------
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
# TESZTELVE: Oracle Linux 9.2 / CentOS 7.9.2009
#
# A SCRIPTET ÍRTA: C2H5Cl, Aethyl-chloride, 2019
# FRISSÍTVE: 2023-06-19
#---------------------------------------------------------------------

#---------------------------------------------------------------------
#--------------------------- BEÁLLÍTÁSOK -----------------------------
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
# IP API URL CÍMEK + BARÁTSÁGOS NEVEK
#
# TETSZŐLEGESEN BŐVÍTHETŐ / CSÖKKENTHETŐ A LISTA
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
#- DINAMIKUS IP / HOSTNAME SZOLGÁLTATÓ (dyn.com / noip.com)
#---------------------------------------------------------------------

DYN_PROVIDER="dyn.com"

#---------------------------------------------------------------------
#- LEGYEN WAN IP VÁLTOZÁSKOR DYN DNS FRISSITES (igen / nem)
#---------------------------------------------------------------------

DYN_UPDATE="igen"

#---------------------------------------------------------------------
#- DYN DNS USER NÉV / UPDATER KEY
#---------------------------------------------------------------------

DYN_UN="dynUserName"
DYN_UPD_KEY="dyn_updater_key"

#---------------------------------------------------------------------
#- NOIP USER / PASSWORD
#---------------------------------------------------------------------

NOIP_UN="noipUserName"
NOIP_PWD="noipPassword"

#---------------------------------------------------------------------
# FRISSITENDO DOMAIN NEVEK
#
# TETSZŐLEGESEN BŐVÍTHETŐ / CSÖKKENTHETŐ A LISTA
# MAX. 20 HOST
#---------------------------------------------------------------------

DYN_DOMAIN[1]="mydyndomain.dyndns.org"
DYN_DOMAIN[2]="example.is-a-geek.org"
DYN_DOMAIN[3]="hello.dyndns.com"
DYN_DOMAIN[4]="mypodcast.mine.nu"
DYN_DOMAIN[5]="iamastreamer.selfip.org"

#---------------------------------------------------------------------
#- CURL USER AGENT BEÁLLÍTÁS (NO-IP.COM MEGKÖVETELI)
#---------------------------------------------------------------------

DYN_USER_AGENT="bash-curl-cron/1.0 anonymous@mail.xyz"

#---------------------------------------------------------------------
#---------------------------------------------------------------------
#------------------------- BEÁLLÍTÁSOK VÉGE --------------------------
#---------------------------------------------------------------------
#---------------------------------------------------------------------

#---------------------------------------------------------------------
#- START WAN IP CHECK + UPDATE
#---------------------------------------------------------------------

echo "$FULLDATUM - IP CHECK ELINDULT..."
echo "$FULLDATUM - IP CHECK ELINDULT..." >> $LOGFAJL

#---------------------------------------------------------------------
#- IP API SZOLGÁLTATÓK + DYN DNS DOMAINEK SZÁMLÁLÁSA
#---------------------------------------------------------------------

UPD_URL_LEN=${#UPD_URL[@]}
DYN_DOMAIN_LEN=${#DYN_DOMAIN[@]}

#---------------------------------------------------------------------
#- ELLENŐRZÉSEK
#---------------------------------------------------------------------

if [ -z $UPD_URL_LEN ] || [ $UPD_URL_LEN == 0 ] ; then

	# NINCS IP API
	FULLDATUM=$(date +"%Y-%m-%d %H-%M-%S")
	echo "$FULLDATUM - NINCS HASZNALHATO IP API URL! - KILEPES"
	echo "$FULLDATUM - NINCS HASZNALHATO IP API URL! - KILEPES" >> $LOGFAJL
	exit 0;

fi

#---------------------------------------------------------------------

if [ -z $DYN_PROVIDER ] || [ $DYN_PROVIDER == "" ] ; then

	DYN_PROVIDER=""
	DYN_UPDATE="nem"

fi

#---------------------------------------------------------------------

if [ -z $DYN_UPDATE ] || [ $DYN_UPDATE == "" ] ; then

	DYN_PROVIDER=""
	DYN_UPDATE="nem"

fi

#---------------------------------------------------------------------

if [ -z $DYN_DOMAIN_LEN ] || [ $DYN_DOMAIN_LEN == 0 ] ; then

	# NINCS DINAMIKUS DOMAIN
	FULLDATUM=$(date +"%Y-%m-%d %H-%M-%S")
	echo "$FULLDATUM - NINCS HASZNALHATO DYN DOMAIN!"
	echo "$FULLDATUM - NINCS HASZNALHATO DYN DOMAIN!" >> $LOGFAJL

	DYN_PROVIDER=""
	DYN_UPDATE="nem"

fi

#---------------------------------------------------------------------
#- DINAMIKUS IP / DNS SZOLGÁLTATÓ BEÁLLÍTÁSOK
#---------------------------------------------------------------------

# dyn.com
if [ ! -z $DYN_PROVIDER ] && [ $DYN_PROVIDER == "dyn.com" ] ; then

	#---------------------------------------------------------------------
	#- DYN.COM UPDATE URL + PARAMETERS
	#---------------------------------------------------------------------

	DYN_UPD_URL="https://${DYN_UN}:${DYN_UPD_KEY}@members.dyndns.org/v3/update"
	DYN_UPD_URL_PARAM1="hostname"
	DYN_UPD_URL_PARAM2="myip"

# no-ip.com
elif [ ! -z $DYN_PROVIDER ] && [ $DYN_PROVIDER == "noip.com" ] ; then

	#---------------------------------------------------------------------
	#- NOIP.COM UPDATE URL + PARAMETERS
	#---------------------------------------------------------------------

	DYN_UPD_URL="https://${NOIP_UN}:${NOIP_PWD}@dynupdate.no-ip.com/nic/update"
	DYN_UPD_URL_PARAM1="hostname"
	DYN_UPD_URL_PARAM2="myip"

# none
else

	DYN_UPDATE="nem"

fi

#---------------------------------------------------------------------
#- EGYÉB VÁLTOZÓK
#---------------------------------------------------------------------

WANIPCIM="x"
MENTETTWANIP="x"
IPCIMTXT="x"
FRISSITSUNK="x"
UPDSVC="x"
HOSTNEVEK="x"
JELALLAPOT="x"

#---------------------------------------------------------------------
#- LOG DIR LÉTREHOZÁSA, HA NEM LÉTEZIK
#---------------------------------------------------------------------

if [ ! -d "$LOGFAJL_DIR" ] ; then
	mkdir -p $LOGFAJL_DIR
	sleep 1
fi

#---------------------------------------------------------------------
# CIKLUSSAL MEGYÜNK VÉGIG A FRISSÍTÉSI SZOLGÁLTATÓKON
# AMINT SIKERESEN LEKÉRDEZZÜK A WAN IP CÍMET, KILÉPÜNK A CIKLUSBÓL
# HA NEM SIKERÜL LEKÉRDEZNI A WAN IP CÍMET EGYIK SZOLGÁLTATÓTÓL SEM,
# ARRÓL ÜZENETET KÜLDÜNK ÉS NAPLÓZZUK IS
#---------------------------------------------------------------------

for (( i=0; i<=${UPD_URL_LEN}; i++ )) ; do

	if [ ! -z "${UPD_URL[$i]}" ] ; then

		FULLDATUM=$(date +"%Y-%m-%d %H-%M-%S")
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

		if [[ "$WANIPCIM" =~ ^(([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))\.){3}([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))$ ]] || [[ $WANIPCIM =~ ^([0-9a-fA-F]{0,4}:){1,7}[0-9a-fA-F]{0,4}$ ]] ; then

			# Okay - valid IP cím
			echo "$FULLDATUM - ${UPD_URL[$i]} - VALID IP CIM: $WANIPCIM"
			echo "$FULLDATUM - ${UPD_URL[$i]} - VALID IP CIM: $WANIPCIM" >> $LOGFAJL
			# Valid IP címet kaptunk a lekérdezés során, kilépünk a cilusból
			break

		else

			# Nem Okay - nem valid az IP cím
			# Nem kaptunk valid IP címet, folytatjuk a ciklust
			echo "$FULLDATUM - ${UPD_URL[$i]} - NEM VALID IP CIM: $WANIPCIM"
			echo "$FULLDATUM - ${UPD_URL[$i]} - NEM VALID IP CIM: $WANIPCIM" >> $LOGFAJL
			WANIPCIM="x"

		fi

	fi

done

#---------------------------------------------------------------------
#- NEM SIKERÜLT A WAN IP LEKÉRDEZÉSE - NAPLÓZUNK, MAJD KILÉPÜNK
#---------------------------------------------------------------------

if [ -z "$WANIPCIM" ] || [ $WANIPCIM == "x" ] ; then

	if [ -f "$IP_ADDR_FAJL" ] ; then

		#---------------------------------------------------------------------
		#- Van ipcim.txt fájl, beszívjuk a tartalmát
		#---------------------------------------------------------------------

		MENTETTWANIP=$(head -n 1 $IP_ADDR_FAJL)

	else

		#---------------------------------------------------------------------
		#- Nincs ipcim.txt fájl
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
#- Megnezzük, van-e ipcim.txt fájl a megadott mappában
#---------------------------------------------------------------------

if [ -f "$IP_ADDR_FAJL" ] ; then

	#---------------------------------------------------------------------
	#- Van ipcim.txt fájl, beszívjuk a tartalmát
	#---------------------------------------------------------------------

	FULLDATUM=$(date +"%Y-%m-%d %H-%M-%S")
	IPCIMTXT="Ok"
	MENTETTWANIP=$(head -n 1 $IP_ADDR_FAJL)

	echo "$FULLDATUM - IP CIM TXT FAJL $IP_ADDR_FAJL LETEZIK..."
	echo "$FULLDATUM - IP CIM TXT FAJL $IP_ADDR_FAJL LETEZIK" >> $LOGFAJL
	echo "$FULLDATUM - JELENLEGI WAN IP CIM: $WANIPCIM"
	echo "$FULLDATUM - KORABBI WAN IP CIM: $MENTETTWANIP"

else

	#---------------------------------------------------------------------
	# Nincs ipcim.txt fájl, létrehozzuk + beírjuk a 0.0.0.0 IP-t a fájlba
	# Ezt később frissítjük az aktuális WAN IP címre
	#---------------------------------------------------------------------

	FULLDATUM=$(date +"%Y-%m-%d %H-%M-%S")
	IPCIMTXT="nOk"
	MENTETTWANIP="0.0.0.0"

	echo "0.0.0.0">$IP_ADDR_FAJL
	echo "$FULLDATUM - IP CIM TXT FAJL $IP_ADDR_FAJL NEM LETEZIK..."
	echo "$FULLDATUM - IP CIM TXT FAJL $IP_ADDR_FAJL NEM LETEZIK - LETREHOZVA (0.0.0.0)" >> $LOGFAJL
	echo "$FULLDATUM - A $IP_ADDR_FAJL LETREHOZVA (0.0.0.0)"
	echo "$FULLDATUM - JELENLEGI WAN IP CIM: $WANIPCIM"

fi

#---------------------------------------------------------------------
#- Ellenőrizzük, hogy a mentett WAN IP egyezik-e a jelenlegivel
#---------------------------------------------------------------------

if [ $WANIPCIM == $MENTETTWANIP ] ; then

	FULLDATUM=$(date +"%Y-%m-%d %H-%M-%S")
	FRISSITSUNK="no"
	echo "$FULLDATUM - WAN IP NEM VALTOZOTT"

else

	FULLDATUM=$(date +"%Y-%m-%d %H-%M-%S")
	FRISSITSUNK="yes"

	# Beírjuk az aktuális WAN IP címet a TXT fájlba
	echo ${WANIPCIM}>$IP_ADDR_FAJL
	echo "$FULLDATUM - WAN IP VALTOZOTT"

fi

#---------------------------------------------------------------------
# Ha a korábbi WAN IP nem egyezik a most lekérdezettel, vagy
# nem létezett a WAN IP címet tartalmazó fájl, akkor az alábbi
# műveleteket hajtjuk végre.
#
# Ezek lehetnek szolgáltatás újraindítások, dinamikus DNS rekordok
# frissítései, bármi egyéb, az alábbiak csak példák
#---------------------------------------------------------------------

if [ $FRISSITSUNK == "yes" ] || [ $IPCIMTXT == "nOk" ] ; then

	if [ $DYN_UPDATE == "igen" ] ; then

		#---------------------------------------------------------------------
		#- DynDNS FRISSÍTÉS - TIMEOUT 15 SEC / MAX. 20 DOMAIN / KÉRÉS
		#---------------------------------------------------------------------
		#- CIKLUSSAL MEGYÜNK VÉGIG A FRISSÍTENDŐ DOMAIN NEVEKEN,
		#- AZOKAT TÖMBBE TESSZÜK
		#---------------------------------------------------------------------

		FULLDATUM=$(date +"%Y-%m-%d %H-%M-%S")

		echo "$FULLDATUM - DINAMIKUS IP SZOLGALTATO: ${DYN_PROVIDER}"
		echo "$FULLDATUM - DINAMIKUS IP SZOLGALTATO: ${DYN_PROVIDER}" >> $LOGFAJL

		HOSTNEVEK=""

		for (( i=0; i<=${DYN_DOMAIN_LEN}; i++ )) ; do

			if [ ! -z "${DYN_DOMAIN[$i]}" ] ; then

				FULLDATUM=$(date +"%Y-%m-%d_%H-%M-%S")

				echo "$FULLDATUM - ${DYN_DOMAIN[$i]} HOZZAADASA A LISTAHOZ..."
				echo "$FULLDATUM - ${DYN_DOMAIN[$i]} HOZZAADASA A LISTAHOZ..." >> $LOGFAJL

				if [ $i == ${DYN_DOMAIN_LEN} ] ; then
				    HOSTNEVEK+="${DYN_DOMAIN[$i]}"
				else
				    HOSTNEVEK+="${DYN_DOMAIN[$i]},"
				fi
			fi
		done

		#---------------------------------------------------------------------

		echo "$FULLDATUM - A KOVETKEZO DOMAIN NEVEK KERULNEK FRISSITESRE:"
		echo "$FULLDATUM - ${HOSTNEVEK}"

		echo "$FULLDATUM - A KOVETKEZO DOMAIN NEVEK KERULNEK FRISSITESRE:" >> $LOGFAJL
		echo "$FULLDATUM - ${HOSTNEVEK}" >> $LOGFAJL

		echo "$FULLDATUM - DYN DNS FRISSITES INDUL..."
		echo "$FULLDATUM - DYN DNS FRISSITES INDUL..." >> $LOGFAJL

		# FRISSÍTÉS
  		ALLAPOT=$(curl "${DYN_UPD_URL}?${DYN_UPD_URL_PARAM1}=${HOSTNEVEK}&${DYN_UPD_URL_PARAM2}=${WANIPCIM}" --user-agent ${DYN_USER_AGENT} --connect-timeout 15 -k -s)
		
		echo "$FULLDATUM - DYN DNS FRISSITES EREDMENYE:"
		echo "${ALLAPOT}"

		echo "$FULLDATUM - DYN DNS FRISSITES EREDMENYE:" >>$LOGFAJL
		echo "$FULLDATUM - ${ALLAPOT}" >> $LOGFAJL

		#---------------------------------------------------------------------
		#- NAPLÓZÁS
		#---------------------------------------------------------------------

		FULLDATUM=$(date +"%Y-%m-%d_%H-%M-%S")

		echo "$FULLDATUM - DynDNS FRISSITESEK BEFEJEZVE... SERVICEK UJRAINDITASA..."
		echo "$FULLDATUM - DynDNS FRISSITESEK BEFEJEZVE..." >> $LOGFAJL
		echo "$FULLDATUM - SERVICEK UJRAINDITASA..." >> $LOGFAJL

		#---------------------------------------------------------------------

	else

		FULLDATUM=$(date +"%Y-%m-%d_%H-%M-%S")
		echo "$FULLDATUM - DynDNS FRISSITES KIKAPCSOLVA..."
		echo "$FULLDATUM - DynDNS FRISSITES KIKAPCSOLVA..." >> $LOGFAJL

	fi

	#---------------------------------------------------------------------
	#- VSFTPD SERVICE LEÁLLÍTÁSA (DEMO)
	#---------------------------------------------------------------------

	FULLDATUM=$(date +"%Y-%m-%d %H-%M-%S")
	echo "$FULLDATUM - VSFTPD LEALLITASA..."
	#systemctl stop vsftpd.service
	#sleep 3

	#---------------------------------------------------------------------
	#- NAPLÓZÁS
	#---------------------------------------------------------------------

	FULLDATUM=$(date +"%Y-%m-%d %H-%M-%S")
	echo "$FULLDATUM - SERVICEK LEALLITVA... WAN IP VALTOZOTT" >> $LOGFAJL

	#---------------------------------------------------------------------
	#- VSFTPD SERVICE INDÍTÁSA (DEMO)
	#---------------------------------------------------------------------

	FULLDATUM=$(date +"%Y-%m-%d %H-%M-%S")
	echo "$FULLDATUM - VSFTPD INDITASA..."
	#systemctl start vsftpd.service
	#sleep 3

	#---------------------------------------------------------------------
	#- WAN IP CÍM MEGVÁLTOZOTT - NAPLÓZÁS
	#---------------------------------------------------------------------

	FULLDATUM=$(date +"%Y-%m-%d %H-%M-%S")
	echo "$FULLDATUM - FRISSITES KESZ... ($UPDSVC)"
	echo "$FULLDATUM - SERVICEK UJRAINDITVA... WAN IP VALTOZOTT" >> $LOGFAJL
	echo "$FULLDATUM - ELOZO WAN IP: $MENTETTWANIP" >> $LOGFAJL
	echo "$FULLDATUM - AKTUALIS WAN IP: $WANIPCIM" >> $LOGFAJL
	echo "$FULLDATUM - FRISSITESI SZOLGALTATAS: $UPDSVC" >> $LOGFAJL
	echo "====================================================================================" >> $LOGFAJL

else

	#---------------------------------------------------------------------
	#- NINCS VÁLTOZÁS - NAPLÓZÁS
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
