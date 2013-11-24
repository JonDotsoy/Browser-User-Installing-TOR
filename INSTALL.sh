#!/bin/bash
# Captura e instalar TOR en el usario

PROGNAME=$0
function error_exit
{
#   ----------------------------------------------------------------
#   Function for exit due to fatal program error
#   	Accepts 1 argument:
#   		string containing descriptive error message
#   ----------------------------------------------------------------
	red='\e[1;31m'
	NC='\e[0m' # No Color
	echo -e "${red}"
    echo "${PROGNAME}: ${1:-"Unknown Error"}" 1>&2
    echo -e "${NC}"
    exit 1
}

so_architecture=$(uname -m)
download_file=/dev/null
language="es-ES"
architecture="x86_64"
version="2.3.25-16"
dir_install="/home/jonathan/.tor-browser/"

echo "Configurando..."

if [ $so_architecture = "x86_64" ]
	then
	architecture="x86_64"
elif [ $so_architecture = "i686" ]
	then
	architecture="i686"
else
	error_exit "$LINENO: No es compatible la arquitectura del equipo."
fi
echo "Configurando con arquitectura $architecture"

if [ -d $dir_installtor-browser_$language ]
	then
	install=false
	if [ -z $1 ]
		then
		read -p "Desear reinstalar TOR? (S/n): " res
		if [ $res = "s" ] || [ $res = "S" ] || [ $res = "SI" ] || [ $res = "si" ]
			then
			install=true
		else
			error_exit "No se ha podido instalar tor. TOR ya esta instalado."
		fi
	else
		if [ $1 = "-y" ]
			then
			install=true
		else
			error_exit "No se ha podido instalar tor. TOR ya esta instalado."
		fi
	fi

	if [ install ]
		then
		rm "$dir_installtor-browser_$language" -R -f
		echo "$dir_installtor-browser_$language Eliminado"
	fi

fi

download_file="https://www.torproject.org/dist/torbrowser/linux/tor-browser-gnu-linux-$architecture-$version-dev-$language.tar.gz"

tem_download_file="/tmp/download$(date +'%N').tar.gz"

url=$download_file
result=$(curl -s -I -L $url | grep ^HTTP | awk '{print $2}')
echo "Comprobando archivo para descargar ($download_file)"
if [ "$result" = "200" ] 
then
    wget -O $tem_download_file $download_file
	tar xzvf $tem_download_file -C "/tmp/"

	mkdir $dir_install -p
	cp "/tmp/tor-browser_$language/" $dir_install -R -f

	echo "Creando Lanzador..."

	echo "[Desktop Entry]" > ~/.local/share/applications/Tor\ Browser.desktop
	echo "Version=1.0" >> ~/.local/share/applications/Tor\ Browser.desktop
	echo "Name=Tor Browser" >> ~/.local/share/applications/Tor\ Browser.desktop
	echo "Comment=Proteja su privacidad. Defiéndete de vigilancia de la red y análisis de tráfico." >> ~/.local/share/applications/Tor\ Browser.desktop
	echo "Exec=$(echo ~)/.tor-browser/tor-browser_es-ES/start-tor-browser" >> ~/.local/share/applications/Tor\ Browser.desktop
	echo "Terminal=false" >> ~/.local/share/applications/Tor\ Browser.desktop
	echo "Type=Application" >> ~/.local/share/applications/Tor\ Browser.desktop
	echo "Icon=tor-browser" >> ~/.local/share/applications/Tor\ Browser.desktop

	chmod 600 ~/.local/share/applications/Tor\ Browser.desktop

	echo "Capturando Icono..."

	wget "https://raw.github.com/alfa30/Browser-User-Installing-TOR/master/icon/tor-logo.svg" -O "/tmp/icon-tor.svg"

	cp "/tmp/icon-tor.svg" "$(echo ~)/.local/share/icons/hicolor/scalable/apps/tor-browser.svg"

	echo "Creando enlace..."

	if [ -f ~/.bash_aliases ]
		then
		touch ~/.bash_aliases
		chmod +x ~/.bash_aliases
	fi
	echo 'alias tor="~/.tor-browser/tor-browser_es-ES/start-tor-browser"' >> ~/.bash_aliases
	echo "Enlace creado"

    rm $tem_download_file && echo "$tem_download_file Eliminado"
else
	error_exit "$LINENO: No se puede descargar el programa, compruebe su conexión a Internet."
fi

echo "Instalación Completa"