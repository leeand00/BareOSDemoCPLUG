#! /bin/bash

# Clear it out
rm ./*.bin

toWhat=$(shuf -i 1-100 -n1)
#echo "toWhat: $toWhat"


# Generate some random files
for n in $( eval echo {0..$toWhat} ); do
  dd if=/dev/urandom of=file$( printf %03d "$n" ).bin bs=1 count=$(( RANDOM + 1024 )) >& /dev/null
done

# Remove some random files
for n in $( eval echo {0..$toWhat} ); do
  rmOne=$(shuf -i 1-100 -n1)
  #echo "rmOne: $rmOne"
  rm ./file$( printf %03d "$rmOne" ).bin 2> /dev/null
done
