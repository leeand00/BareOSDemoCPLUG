#!/bin/bash
echo "updating vboxadd-service file..."
sudo sed -i.bak  "s%\(daemon \$binary\) \(--pidfile \$PIDFILE > \/dev\/null\)%\1 --disable-timesync \2%g" /opt/VBoxGuestAdditions-5.0.40/init/vboxadd-service && sudo rm -rf /opt/VBoxGuestAdditions-5.0.40/init/vboxadd-service.bak
echo "updating vboxadd-service file...again"
sudo sed -i.bak '0,/start-stop-daemon --start --exec \$1 -- \$2 \$3/{s/start-stop-daemon --start --exec \$1 -- \$2 \$3/\0 $4/}'  /opt/VBoxGuestAdditions-5.0.40/init/vboxadd-service && sudo rm -rf /opt/VBoxGuestAdditions-5.0.40/init/vboxadd-service.bak 
echo "reloading daemons..."
sudo systemctl daemon-reload
echo "restarting vboxadd-service"
sudo systemctl restart vboxadd-service
