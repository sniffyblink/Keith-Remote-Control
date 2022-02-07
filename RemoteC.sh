#!/bin/bash

#Installing applications
#Nipe - Anonymous
#GeoIP - To check our location

echo 'Hello! Welcome to Remote Control'
echo ""


#checking for GeoIP/Install GeoIP

sudo updatedb
geo=$(sudo locate geoip-bin)

if [[ -z $geo ]]
then 
	echo 'Installing GeoIP services!.........'
	sudo apt-get install geoip-bin
	
else
	
	echo "[!]GeoIP Already Installed[!]"
	echo ""
	echo ""
fi


sudo updatedb
pathname=$(pwd) 


#Checking for nipe/Install nipe

nip=$(sudo locate nipe.pl)
NIPLOC=$(sudo locate nipe.pl| rev | cut -c9- |rev) #remove the nipe.pl 

if [[ -z $nip ]]
then 
	cd ~
	echo "Creating Directory called Remote .........."
	mkdir Remote 2>/dev/null
	cd ~/Remote
	echo 'Installing Nipe...........'
	git clone https://github.com/htrgouvea/nipe
	cd ~/Remote/nipe                                 #cd ~/Remote/nipe
	sudo cpan install Try::Tiny Config::Simple JSON
	sudo perl nipe.pl install
	
else
	cd ~
	mkdir Remote 2>/dev/null
	echo "[!]Nipe Already Installed[!]"
	echo ""
	echo ""
	sleep 2
	echo "Creating Directory called Remote .........."
	cp -r $NIPLOC ~/Remote 2>/dev/null
fi


#Check if the connection is anonymous

echo ""
echo ""
echo " --[!]Running Anonymous Check[!]-- "
echo ""
echo ""

cd ~/Remote/nipe
sudo updatedb
sudo perl nipe.pl restart
sudo perl nipe.pl stop
sleep 2

per=$(sudo perl nipe.pl status | grep activated)

if [[ -z $per ]]
then
    echo "[!]Your not Anonymous!! Turning Anonymous[!]"
    echo ""
    echo ""
	cd ~/Remote/nipe
	echo "Starting Nipe.........."
	sudo perl nipe.pl start
	curlip=$(curl ifconfig.me)
	curlloc=$(geoiplookup $curlip | sed 's/GeoIP Country Edition//')
	echo ""
	echo ""
	echo "Change Sucessful!"
	echo "You are now surfing with $curlip in $curlloc"
	sleep 2
	echo "Proceeding ............"
else
	echo "[!]You are already Anonymous[!]"
	echo ""
	echo ""
	curlip=$(curl ifconfig.me)
	curlloc=$(geoiplookup $curlip | sed 's/GeoIP Country Edition//')
	echo "You are now surfing with $curlip in $curlloc"
	echo ""
	echo ""
	echo "Proceeding ............"
	echo ""
	echo ""
fi



#Generate Keypass

function KEYGEN {
	echo "-----BEGIN RSA PRIVATE KEY-----" > keypass 
	XXXXXXXX 
	echo "-----END RSA PRIVATE KEY-----" >> keypass
}

#Checking Keypass/Installing Keypass

cd ~/Remote #change pwd ~/Remote

sudo updatedb
key=$(locate keypass)

echo "Checking for keypass ........"
echo ""

if [[ -z $key  ]]
then 
	echo "[!]Keypass not found[!]"
	echo "[!]Generating Keypass[!]"
	KEYGEN
else
	echo ""
	echo "[!]Keypass is already Installed[!]"
	cp $key ~/Remote 2>/dev/null
fi

chmod 400 keypass #give permissions!
echo ""
echo ""


function connectremote {
	
read -p "Would you like to connect to remote server?[y/n]" chec

case $chec in
	y)
	echo ""
	echo ""
	echo "[!]Connecting to Remote Server, please wait..........."
	sleep 2
	;;
	n)
	echo ""
	echo ""
	echo "Thank You!, Goodbye"
	cd ~/Remote/nipe
	sudo perl nipe.pl stop
	sleep 2
	exit 
	;;
	*)
	echo ""
	echo ""
	echo "Not a valid choice: Please try again."
	sleep 2
	connectremote
	;;
esac

}

connectremote

#3. Connect automatically to the VPS and execute tasks
# ssh -i "webserver1-keypair.pem" ec2-user@ec2-3-0-19-113.ap-southeast-1.compute.amazonaws.com

function recon_main_menu {
	
clear	
	
cat <<_EOF_

   ----------------------------
   - Welcome to Recon Server! -
   ----------------------------
   
   
Press the number of your choice


	1. Nmap Scan ( Settings preset at -v -T4 -O -oG )
	2. Whois Scan


	3. Access Archive


	0. Quit

_EOF_

read -n 1 -s choice;
	
	case $choice in
	
	
		1)
		echo "[!]Nmap Selected[!]"
		read -p "Please enter IP/URL to scan: " IP
		read -p "Please enter name to save file to: " NAME
		echo "Please wait ........"
		ssh -i "keypass" ec2-user@ec2-3-0-19-113.ap-southeast-1.compute.amazonaws.com "cd /home/ec2-user/Archive; sudo nmap -v -T4 -O $IP -oG '$NAME'"
		echo ""
		echo ""
		echo " --- ! Scan Results! ---"
		echo ""
		echo ""
		echo ""
		ssh -i "keypass" ec2-user@ec2-3-0-19-113.ap-southeast-1.compute.amazonaws.com "cd /home/ec2-user/Archive; cat '$NAME'"
		echo ""
		echo ""
		echo " --- ! Scan is Finished ! ---"
		echo ""
		echo " --- ! A backup copy has been saved into the Archive folder ---"
		echo ""
		echo ""
		sleep 2
		downloadcheck
		
		;;
		
		
		2)
		echo "[!]whois selected[!]"
		read -p "Please enter IP/URL to scan: " IP
		read -p "Please enter name to save file to: " NAME
		echo "Please wait ........."
		ssh -i "keypass" ec2-user@ec2-3-0-19-113.ap-southeast-1.compute.amazonaws.com "cd /home/ec2-user/Archive; whois $IP > '$NAME'"
		echo ""
		echo ""
		echo " --- ! Scan Results! ---"
		echo ""
		echo ""
		echo ""
		ssh -i "keypass" ec2-user@ec2-3-0-19-113.ap-southeast-1.compute.amazonaws.com "cd /home/ec2-user/Archive; cat '$NAME'"
		echo ""
		echo ""
		echo " --- ! Scan is Finished ! ---"
		echo ""
		echo " --- ! A backup copy has been saved into the Archive folder ---"
		echo ""
		echo ""
		sleep 2
		downloadcheck
		
		;;
		
		3)
		archive
		;;
		
		0)
		echo " --- Thank you for using Recon Server ---"
		cd ~/Remote/nipe
		sudo perl nipe.pl stop
		echo " Goodbye ...... "
		echo ""
		echo ""
		usernotes
		exit
		;;
		
		
		*)
		echo "Not a valid choice: Please try again."
		sleep 2
		clear
		recon_main_menu
		;;
	esac
	
}

function downloadcheck {
read -p "Would you like to download the file?[y/n]" chec

	case $chec in
		y)
		echo "Please wait ..........."
		scp -r -i "keypass" ec2-user@ec2-3-0-19-113.ap-southeast-1.compute.amazonaws.com:/home/ec2-user/Archive/"'$NAME'" $pathname
		echo ""
		echo ""
		echo "File saved to $pathname"
		echo ""
		echo ""
		returnMain
		;;
		
		n)
		echo ""
		echo ""
		echo " --- ! Please Access Archives if you wish to download the file. Thank You ---"
		echo ""
		echo ""
		
		returnMain
		;;
		
		*)
		echo "Not a valid choice: Please try again."
		sleep 2
		downloadcheck
	esac

}
	
	
pathname=$(pwd) 	
	
function archive {	
	
pathname=$(pwd) 	

clear

echo ""
echo ""
echo "----- Welcome to the ARCHIVES Folder! -----"	
echo ""
echo "[!]Loading files!..."
echo ""
echo ""
ssh -i "keypass" ec2-user@ec2-3-0-19-113.ap-southeast-1.compute.amazonaws.com "cd /home/ec2-user/Archive; ls "
echo ""
echo ""
echo ""
	
cat << _EOF_
 
	- Press [v] to view file
	- Press [d] to download file
	- Press [r] to return to Recon Main Menu

_EOF_


read -n 1 -s choice;

	case $choice in

#View File
		
		v)
		read -p "Please type filename to view :" NAME
		[ -f '$NAME' ] && echo "Opening file, please wait ............ ";
		ssh -i "keypass" ec2-user@ec2-3-0-19-113.ap-southeast-1.compute.amazonaws.com "cd /home/ec2-user/Archive; cat '$NAME'" 2>/dev/null || echo "[!]Error Input[!] Please try again!" 
		echo ""
		echo ""
		returnarchive
		
		;;
		
		d)
		read -p "Please type filename to Download:" NAME
		[ -f '$NAME' ] && echo "Downloading file, please wait .......... ";
		scp -r -i "keypass" ec2-user@ec2-3-0-19-113.ap-southeast-1.compute.amazonaws.com:/home/ec2-user/Archive/"'$NAME'" $pathname 2>/dev/null || echo "[!]Error Input[!] Please try again!"
		echo ""
		echo ""
		echo "File saved to $pathname"
		echo ""
		echo ""
		returnarchive
		;;
		
		r)
		echo "Returning to Recon Menu, please wait ................ "
		sleep 2
		clear
		recon_main_menu
		;;
		
		*)
		
		echo "Not a valid choice: Please try again."
		sleep 2
		clear
		archive
		;;
	esac
}	

function returnarchive {

cat <<_EOF_

	- Press [r] to return to Archive menu

_EOF_
	
	read -n 1 -s choice;
	case $choice in	
	
		r)
		archive
		;;
		
		*)
		echo "Not a valid choice: Please try again."
		sleep 2
		returnarchive
		;;
	esac
}

function returnMain {

cat <<_EOF_

	- Press [r] to return to Recon Menu

_EOF_
	
	read -n 1 -s choice;
	case $choice in	
	
		r)
		recon_main_menu
		;;
		
		*)
		echo "Not a valid choice: Please try again."
		sleep 2
		returnMain
		;;
	esac
}


function usernotes {

cat <<_EOF_

User Notes

- NMAP settings have been preset to  -v -T4 -O -oG
	
	- -v: Increase verbosity level
	- -T4: for faster execution
	- -O: Enable OS detection
	- -oG: saved file in Grepable format

- All downloaded files have been saved in your  ~/Remote folder.

- A copy of the 'keypass' has been saved in your ~/Remote folder. If u wish to access Recon Server manually, 
  u can do so by using this command. 
  
 
  ssh -i "keypass" ec2-user@ec2-3-0-19-113.ap-southeast-1.compute.amazonaws.com
  
  
- [!]Make sure u are in the folder where the 'keypass' is stored when execuing the command[!]


            
            -- !!! THANK YOU !!! -- 
			
_EOF_
 
}

recon_main_menu #executes the recon server


