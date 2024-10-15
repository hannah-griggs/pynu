#!/bin/bash

# Wrapper script to run the steps of the PyNu analysis

# Identificaiton info for PyNu runs
grbid='170125022'
grbtime=1169339491.70
chunk='4'
input_directory='/home/hannah.griggs/nu/pynu_tests/o2grbs/results'
time_window=10

jobs=$1

if [[ $jobs =~ "c" ]]; then
        # Run the CSV creator/merger
        echo
	echo 'Running csv_maker....'
        python3 csv_maker.py $grbid $chunk $input_directory
fi
if [[ $jobs =~ "b" ]]; then
        # Run the background statistics calculation
        echo
	echo 'Running backround calculation....'
        python3 backgroundpval.py $grbid $chunk $input_directory
fi
if [[ $jobs =~ "f" ]]; then
        # Run the foreground pvalue calculation
        echo
	echo 'Running foreground calculation....'
        python3 foregroundpval.py $grbid $grbtime $input_directory $time_window
fi

echo 'Done.'
