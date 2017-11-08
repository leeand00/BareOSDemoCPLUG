#!/bin/bash

# Cleans the VM of snapshots and clears out the output from 
# the configuration test run.

for i in $(seq 0 $1)
   do
   vagrant snapshot delete bareOSdirector ${i}
done

rm ./testlog/*
rm ./testlog/csv/*
