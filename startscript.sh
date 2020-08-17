#!/bin/bash
set -e
#cp /cache-clean.sh /p4/config/
#cron

export LOGFILE=/p4/logs/$P4P_VER-$(date '+%Y-%m-%d-%H-%M-%S').log
export P4SSLDIR=/p4/ssl
export P4PCACHELOCATION=/p4/cache
mkdir -p $P4PCACHELOCATION
printenv >> $LOGFILE

export P4TARGET=${P4PTARGET,,}
if [ "${P4PTARGET:0:3}" == "ssl" ]; then
/p4/bin/p4 -p $P4PTARGET trust -y 2>&1 >> $LOGFILE
fi

export P4PPORT=${P4PPORT,,}
if [ "${P4PPORT:0:3}" == "ssl" ]; then
chmod 700 $P4SSLDIR 2>&1 >> $LOGFILE
if [[ ( ! -f "$P4SSLDIR/certificate.txt" ) || ( ! -f "$P4SSLDIR/privatekey.txt" ) ]]; then
/p4/bin/p4p -Gc 2>&1 >> $LOGFILE
fi
fi

export P4PCOMPRESS=${P4PCOMPRESS^^}
if [ "$P4PCOMPRESS" == "TRUE" ]; then
/p4/bin/p4p -p $P4PPORT -t $P4PTARGET -r $P4PCACHELOCATION -L $LOGFILE -i -v proxy.monitor.level=3 -v proxy.monitor.interval=0
else
/p4/bin/p4p -p $P4PPORT -t $P4PTARGET -c -r $P4PCACHELOCATION -L $LOGFILE -i -v proxy.monitor.level=3 -v proxy.monitor.interval=0
fi