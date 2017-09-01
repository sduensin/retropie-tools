#!/bin/bash -e

# ----- License --------------------------------------------------------------
#
#  install-munt.sh
#
#  Copyright 2017 Scott Duensing <scott@duensing.com>
#
#  This work is free. You can redistribute it and/or modify it under the
#  terms of the Do What The Fuck You Want To Public License, Version 2,
#  as published by Sam Hocevar. See the COPYING file or visit 
#  http://www.wtfpl.net/ for more details.
#
# ----- History --------------------------------------------------------------
#
#  01-SEP-2017 - Initial Release
#
# ----------------------------------------------------------------------------

apt-get -y install build-essential cmake portaudio19-dev qtmobility-dev libx11-dev libxt-dev libxpm-dev

wget https://github.com/munt/munt/archive/munt_2_2_0.tar.gz
tar -xzf munt_2_2_0.tar.gz
rm munt_2_2_0.tar.gz

cd munt-munt_2_2_0
mkdir build
cd build
export CCFLAGS="-Ofast -mcpu=cortex-a53"
export CXXFLAGS="-Ofast -mcpu=cortex-a53"
cmake -DCMAKE_BUILD_TYPE=Release -Dmunt_WITH_MT32EMU_QT:BOOL=OFF ..
make -j 4
make install
cd ../mt32emu_alsadrv
make
make install
cd ../..

mkdir /usr/share/mt32-rom-data
chmod 777 /usr/share/mt32-rom-data
# https://drive.google.com/drive/folders/0B5j-_ZMS8_UoY2MxOWRmMzktZmZhOS00M2EwLWFkZGItODNmODY4ZjU5Y2Vi
wget 'https://drive.google.com/uc?export=download&id=0B5j-_ZMS8_UoYjM4NjZhYWMtNjk2NS00OTkxLTgyZDMtODBhZTVhMzA3Y2M5' -O /usr/share/mt32-rom-data/CM32L_CONTROL.ROM
wget 'https://drive.google.com/uc?export=download&id=0B5j-_ZMS8_UoODIyNGJmMmMtOWFmZS00ZGEyLTk1NTMtZGFlZWFiOTBmY2Jm' -O /usr/share/mt32-rom-data/CM32L_PCM.ROM
wget 'https://drive.google.com/uc?export=download&id=0B5j-_ZMS8_UoZWQxNWE0N2UtOWVlZS00NTFiLTk2OTYtMGM4ZmNmZDI3NWIz' -O /usr/share/mt32-rom-data/MT32_CONTROL.ROM
wget 'https://drive.google.com/uc?export=download&id=0B5j-_ZMS8_UoNzdkYjRiMGUtMmY4MS00YTE3LWI2NWEtMjE0ZmJkYmRmMmU2' -O /usr/share/mt32-rom-data/MT32_PCM.ROM
chmod 444 /usr/share/mt32-rom-data/*.ROM

sed -i 's/^midiconfig=$/midiconfig=128:0/' /home/pi/.dosbox/dosbox-SVN.conf

grep -q MT32 /etc/rc.local
if [[ $? -ne 0 ]]; then
	sed -i 's/^exit 0/# Start MT32 Emulation/' /etc/rc.local
	echo 'echo performance > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor' >> /etc/rc.local
	echo '/usr/local/bin/mt32d -i 12 &' >> /etc/rc.local
	echo 'exit 0' >> /etc/rc.local
fi
