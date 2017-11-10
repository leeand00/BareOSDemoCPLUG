# BareOS Demo for the Harrisburg CPLUG
## Andrew J. Leer

Note that this requires a VT-x CPU for 64-bit virtualization.

The updateTimesNWeeks.sh script is there to test the GFS setup and output the results to /testlog

1. This was tested with VirtualBox 5.0.40_Ubuntu r11530 and Vagrant 1.8.1
1. Install the following plugins and versions:
  1. vagrant-host-shell (0.0.4)
  1. vagrant-hostmanager (1.8.7)
  1. vagrant-hostsupdater (1.0.2)
  1. vagrant-mutate (1.2.0)
  1. vagrant-scp (0.5.7)
  1. vagrant-share (1.1.6, system)
  1. vagrant-triggers (0.5.3)
  1. vagrant-vbguest (0.15.0)
1. Run `vagrant up bareOSdirector`
1. Run `vagrant up webserver`
1. Run `./updateTimesNWeeks.sh 11` (or any number 1-53, depending on the year and what week you want it to backup to...)


