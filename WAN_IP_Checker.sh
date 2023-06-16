#!/bin/bash

#---------------------------------------------------------------------
# WAN IP CIM LEKERDEZO / ELLENORZO / DYN DNS FRISSITO SCRIPT (PL. CRONJOB)
# EZZEL A SCRIPTTEL 4 KULONBOZO SZOLGALTATOTOL KERDEZHETJUK LE
# A PUBLIKUS (WAN) IP CIMUNKET. AZ ELSO VALID IP CIM LEKERDEZES UTAN
# A SCRIPT TOVABBLEP, NEM ELLENORZI VEGIG MIND AZ 4 IP CÍM API-T.
# A 4 IP API A REDUNDANCIA MIATT VAN A PROGRAMBAN
#
# AMENNYIBEN MEGVALTOZOTT A WAN IP CIMUNK A KORABBAN MENTETTHEZ
# KEPEST, AKKOR KULONBOZO MUVELETEKET HAJTHAUNK VEGRE, PL.
# DINAMIKUS DNS SZOLGALATATONAL HASZNALT DOMAIN NEV / IP CIM
# FRISSITEST, SZOLGALTATASOK UJRAINDITASAT, ERTESITEST STB.
#
# A SCRIPT NAPLOZZA A MUKODESET
#
# IRTA: C2H5Cl, Aethyl-chloride, 2019
# UPDATED: 2023-06-16
#---------------------------------------------------------------------


#---------------------------------------------------------------------
# BEALLITASOK
#---------------------------------------------------------------------

#---------------------------------------------------------------------
#- WAN IP TEXT FAJL ABS PATH
#---------------------------------------------------------------------

IP_ADDR_FAJL="/var/log/wanipaddress.txt"

#---------------------------------------------------------------------
#- DATUMOK + LOG FILE DIR + FILE
#---------------------------------------------------------------------

DATUM=$(date +"%Y-%m-%d")
LOGDATUM=$(date +"%Y-%m-%d")
FULLDATUM=$(date +"%Y-%m-%d %H-%M-%S")

LOGFAJL_DIR="/var/log/WANIPChange"
LOGFAJL="$LOGFAJL_DIR/$LOGDATUM.txt"

#---------------------------------------------------------------------
#- IP API URL CIMEK + BARATSAGOS NEVEK
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
#- LEGYEN WAN IP VALTOZASKOR DYN DNS FRISSITES (igen / nem)
#---------------------------------------------------------------------

DYN_UPDATE="nem"

#---------------------------------------------------------------------
#- DYN DNS USER NAME / UPDATE KEY
#---------------------------------------------------------------------

DYN_UN="userName"
DYN_UPD_KEY="1234567890abcdef1234567890abcde"

#---------------------------------------------------------------------
#- DYN DNS FRISSITENDO DOMAIN NEVEK
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
#- EGYEB VALTOZOK
#---------------------------------------------------------------------

WANIPCIM="x"
MENTETTWANIP="x"
IPCIMTXT="x"
FRISSITSUNK="x"
UPDSVC="x"

#---------------------------------------------------------------------
#- LOG DIR LETREHOZASA, HA NEM LETEZIK
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
# CIKLUSAL MEGYUNK VEGIG A FRISSITESI SZOLGALTATOKON
# AMINT SIKERESEN LEKERDEZZUK A WAN IP CIMET, KILEPUNK A CIKLUSBOL
# HA NEM SIKERUL, ARROL UZENETET KULDUNK ES NAPLOZZUK IS
#---------------------------------------------------------------------

for i in 1 2 3 4

	do
 
		if [ ! -z "${UPD_URL[$i]}" ] ; then

	 		echo "$FULLDATUM - ${UPD_URL[$i]} - WAN IP LEKERDEZESE..."
			echo "$FULLDATUM - ${UPD_URL[$i]} - WAN IP LEKERDEZESE..." >> $LOGFAJL
			WANIPCIM=$(curl "${UPD_URL[$i]}" --connect-timeout 20 -k -s)
			UPDSVC=${UPD_URL_NAME[$i]}
			FULLDATUM=$(date +"%Y-%m-%d %H-%M-%S")

			#---------------------------------------------------------------------

			if [[ "$WANIPCIM" =~ ^(([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))\.){3}([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))$ ]] ; then
	 
				# Okay - valid IP cim
				echo "$FULLDATUM - ${UPD_URL[$i]} - VALID IP CIM: $WANIPCIM"
				echo "$FULLDATUM - ${UPD_URL[$i]} - VALID IP CIM: $WANIPCIM" >> $LOGFAJL
				break
		
			else
	 
				# Nem Okay - nem valid IP cim
				echo "$FULLDATUM - ${UPD_URL[$i]} - NEM VALID IP CIM: $WANIPCIM"
				echo "$FULLDATUM - ${UPD_URL[$i]} - NEM VALID IP CIM: $WANIPCIM" >> $LOGFAJL
				WANIPCIM="x"
		
			fi
	 
		fi

	done

#---------------------------------------------------------------------
# NEM SIKERULT A WAN IP LEKERDEZESE - KILEPUNK
#---------------------------------------------------------------------

if [ -z "$WANIPCIM" ] || [ $WANIPCIM == "x" ] ; then

	if [ -f "$IP_ADDR_FAJL" ] ; then
		#---------------------------------------------------------------------
		# Van ipcim.txt fajl, beszivjuk a tartalmat
		#---------------------------------------------------------------------
		MENTETTWANIP=$(head -n 1 $IP_ADDR_FAJL)
	else
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
# Megnezzuk, van-e ipcim.txt fajl a megadott mappaban
#---------------------------------------------------------------------

if [ -f "$IP_ADDR_FAJL" ] ; then

	#---------------------------------------------------------------------
	# Van ipcim.txt fajl, beszivjuk a tartalmat
	#---------------------------------------------------------------------

	FULLDATUM=$(date +"%Y-%m-%d %H-%M-%S")
	IPCIMTXT="Ok"
	echo "$FULLDATUM - VAN IP CIM FAJL..."
	MENTETTWANIP=$(head -n 1 $IP_ADDR_FAJL)
	echo "$FULLDATUM - JELENLEGI WAN IP CIM: $WANIPCIM"
	echo "$FULLDATUM - KORABBI WAN IP CIM: $MENTETTWANIP"
	echo "$FULLDATUM - VAN IP CIM TXT" >> $LOGFAJL
	sleep 1

	#---------------------------------------------------------------------
	# Nincs ipcim.txt fajl, letrehozzuk, beirjuk az aktualis WAN IP-t
	#---------------------------------------------------------------------

else

	#---------------------------------------------------------------------

	FULLDATUM=$(date +"%Y-%m-%d %H-%M-%S")
	IPCIMTXT="nOk"
	echo "0.0.0.0">$IP_ADDR_FAJL
	echo "$FULLDATUM - NINCS IP CIM FAJL..."
	echo "$FULLDATUM - A $IP_ADDR_FAJL LETREHOZVA! (0.0.0.0)"
	echo "$FULLDATUM - JELENLEGI IP CIM: $WANIPCIM"
	echo "$FULLDATUM - NINCS IP CIM TXT - LETREHOZVA" >> $LOGFAJL
	sleep 1
	MENTETTWANIP=$(head -n 1 $IP_ADDR_FAJL)
	sleep 3

fi

#---------------------------------------------------------------------
# Ellenorizzuk, hogy a mentett WAN IP egyezik-e a jelenlegivel
#---------------------------------------------------------------------

if [ $WANIPCIM == $MENTETTWANIP ] ; then

	FULLDATUM=$(date +"%Y-%m-%d %H-%M-%S")
	FRISSITSUNK="no"
	echo "$FULLDATUM - NINCS WAN IP VALTOZAS!"
	sleep 1

else

	FULLDATUM=$(date +"%Y-%m-%d %H-%M-%S")
	FRISSITSUNK="yes"
	echo ${WANIPCIM}>$IP_ADDR_FAJL
	sleep 1
	echo "$FULLDATUM - VAN WAN IP VALTOZOTT!"
	sleep 1

fi

#---------------------------------------------------------------------
# Ha a korabbi WAN IP nem egyezik a most lekerdezettel, vagy
# nem letezett a WAN IP cimet tartalmazo fajl, akkor az alabbi
# muveleteket hajtjuk vegre.
# Ezek lehetnek szolgaltatas ujrainditasok, dinamikus DNS rekordok
# frissitesei, barmi egyeb, az alabbiak csak peldak
#---------------------------------------------------------------------

if [ $FRISSITSUNK == "yes" ] || [ $IPCIMTXT == "nOk" ] ; then

	#---------------------------------------------------------------------
	# HA A DYN_UPDATE ERTEKE IGEN, AKKOR FRISSITJUK A DYN DNS NEVEKET
	#---------------------------------------------------------------------

	if [ $DYN_UPDATE == "igen" ] ; then

		#---------------------------------------------------------------------
		# DynDNS FRISSITES - TIMEOUT 15 SEC
		#---------------------------------------------------------------------
		# CIKLUSAL MEGYUNK VEGIG A FRISSITENDO DOMAIN NEVEKEN
		#---------------------------------------------------------------------

		for i in 1 2 3 4 5 6 7 8 9

			do

				if [ ! -z "${DYN_DOMAIN[$i]}" ] ; then
					FULLDATUM=$(date +"%Y-%m-%d_%H-%M-%S")
					echo "$FULLDATUM - ${DYN_DOMAIN[$i]} FRISSITESE..."
					echo "$FULLDATUM - ${DYN_DOMAIN[$i]} FRISSITESE..." >> $LOGFAJL
		 			echo "https://$DYN_UN:$DYN_UPD_KEY@members.dyndns.org/v3/update?hostname=${DYN_DOMAIN[$i]}&myip=${WANIPCIM} --connect-timeout 15 -k -s"
		 			#curl "https://$DYN_UN:$DYN_UPD_KEY@members.dyndns.org/v3/update?hostname=${DYN_DOMAIN[$i]}&myip=${WANIPCIM}" --connect-timeout 15 -k -s
					sleep 2
				fi

			done

		#---------------------------------------------------------------------
		# NAPLOZAS
		#---------------------------------------------------------------------
	
		FULLDATUM=$(date +"%Y-%m-%d_%H-%M-%S")
	
		echo "$FULLDATUM - ORACLE / DynDNS FRISSITESEK BEFEJEZVE... SERVICEK UJRAINNDITASA..."
		echo "$FULLDATUM - ORACLE / DynDNS FRISSITESEK BEFEJEZVE..." >> $LOGFAJL
		echo "$FULLDATUM - SERVICEK UJRAINDITASA..." >> $LOGFAJL
		sleep 1
	
		#---------------------------------------------------------------------
	
	else
	
		echo "$FULLDATUM - DYN DNS FRISSITES KIKAPCSOLVA..."
		echo "$FULLDATUM - DYN DNS FRISSITES KIKAPCSOLVA..." >> $LOGFAJL
	
	fi

	#---------------------------------------------------------------------
	# VSFTPD SERVICE LEALLITASA
	#---------------------------------------------------------------------
	
	FULLDATUM=$(date +"%Y-%m-%d %H-%M-%S")
	echo "$FULLDATUM - VSFTPD LEALLITASA..."
	# systemctl stop vsftpd.service
	sleep 2
	
	#---------------------------------------------------------------------
	# NGINX SERVICE LEALLITASA
	#---------------------------------------------------------------------
	
	# FULLDATUM=$(date +"%Y-%m-%d %H-%M-%S")
	# echo "$FULLDATUM - NGINX LEALLITASA..."
	# systemctl stop nginx.service
	# sleep 2
	
	#---------------------------------------------------------------------
	# PHP-FPM SERVICE LEALLITASA
	#---------------------------------------------------------------------
	
	# FULLDATUM=$(date +"%Y-%m-%d %H-%M-%S")
	# echo "$FULLDATUM - PHP72-FPM LEALLITASA..."
	# systemctl stop php72-php-fpm.service
	# sleep 2
	
	
	#---------------------------------------------------------------------
	# NAPLOZAS
	#---------------------------------------------------------------------
	
	FULLDATUM=$(date +"%Y-%m-%d %H-%M-%S")
	echo "$FULLDATUM - SERVICEK LEALLITVA... WAN IP VALTOZOTT" >> $LOGFAJL
	
	#---------------------------------------------------------------------
	# PHP-FPM SERVICE INDITASA
	#---------------------------------------------------------------------
	
	# FULLDATUM=$(date +"%Y-%m-%d %H-%M-%S")
	# echo "$FULLDATUM - PHP72-FPM INDITASA..."
	# systemctl start php72-php-fpm.service
	# sleep 2
	
	#---------------------------------------------------------------------
	# NGINX SERVICE INDITASA
	#---------------------------------------------------------------------
	
	# FULLDATUM=$(date +"%Y-%m-%d %H-%M-%S")
	# echo "$FULLDATUM - NGINX INDITASA..."
	# systemctl start nginx.service
	# sleep 2
	
	#---------------------------------------------------------------------
	# VSFTPD SERVICE INDITASA
	#---------------------------------------------------------------------
	
	FULLDATUM=$(date +"%Y-%m-%d %H-%M-%S")
	echo "$FULLDATUM - VSFTPD INDITASA..."
	# systemctl start vsftpd.service
	sleep 2

	#---------------------------------------------------------------------
	# NAPLOZAS
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
	# NAPLOZAS
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
