#!/bin/bash

# This is the script run to create the PhaseTD statistic histograms for signal
# rate calculation. 
# Modified for PyNu tests: HG

# Note: pycbc_dtphase used to be called pycbc_multiifo_dtphase

# Check if the right amount of arguments are provided
if [ "$#" -ne 5 ]; then
    echo "Usage: $0 <grb-name> <gps-time> <ra> <dec> <sky-error>"
    exit 1
fi

IFOS='HL'

# Set up the inputs
ra_center=$3
dec_center=$4

diameter=$5 # Diameter around center
if (( $(echo "$diameter < 5.0" |bc -l) )); then
      diameter=5.0
fi

p_special=0.8 # Define the probability of sampling from the specified RA and DEC range
p_special_perc=$(echo "$p_special * 100" | bc -l)
offset=0.0 #usual 0.0, make sure to enter a float
diameter_event=$(echo $diameter | sed 's/\./pt/g')
event_name="GRB$1"

declare -a ifos=('L1' 'H1' 'V1')
declare -a rel_sens=(1 0.8 0.3) # relative sensitivities
three_ifo_sample_size=80000 # Original 80000000
two_ifo_sample_size=80000 # Original 8000000 #lately i've been using 80000 standard 800000 denser
batch_size=100000 #default 1000000 #O3 2000000
snr_ratio=3.0
seed=10
snr_reference=4
snr_uncertainty=1

two_ifo_timing_uncertainty=0.0005
three_ifo_timing_uncertainty=0.001
two_ifo_smoothing_sigma=3
three_ifo_smoothing_sigma=2
two_ifo_bin_density=4 #was 4 # I had this as 10, I can test 4
three_ifo_bin_density=3 #was 2 #I had this as 6 for some reason
two_ifo_pb_dtype=int32
three_ifo_pb_dtype=int8

# Calculate RA and DEC ranges
ra_min=$(echo "$ra_center + $offset - $diameter / 2" | bc -l)
ra_max=$(echo "$ra_center + $offset + $diameter / 2" | bc -l)
dec_min=$(echo "$dec_center - $diameter / 2" | bc -l)
dec_max=$(echo "$dec_center + $diameter / 2" | bc -l)

trig_time=$2

echo
echo "Beginning generation..."

weight_threshold=0.000001
pycbc_dtphase_pynu \
      --ifos ${ifos[0]} ${ifos[1]} \
      --relative-sensitivities ${rel_sens[0]} ${rel_sens[1]} \
      --sample-size ${two_ifo_sample_size} \
      --batch-size ${batch_size} \
      --snr-ratio ${snr_ratio} \
      --seed ${seed} \
      --snr-reference ${snr_reference} \
      --output-file ${ifos[0]}${ifos[1]}-stat-${event_name}.hdf \
      --timing-uncertainty ${two_ifo_timing_uncertainty} \
      --smoothing-sigma ${two_ifo_smoothing_sigma} \
      --snr-uncertainty ${snr_uncertainty} \
      --weight-threshold ${weight_threshold} \
      --ra-min ${ra_min} \
      --ra-max ${ra_max} \
      --dec-min ${dec_min} \
      --dec-max ${dec_max} \
      --trig-time ${trig_time} \
      --bin-density ${two_ifo_bin_density} \
      --param-bin-dtype ${two_ifo_pb_dtype} \
      --p-special ${p_special} \
      --verbose

# Print config to log
if [ ! -d "logs" ]; then
  mkdir logs
fi
cd logs

printf "event_name=$event_name\n\
ifos=$IFOS\n\
trig_time=$trig_time\n\
p_special=$p_special\n\
ra_min=$ra_min\n\
ra_max=$ra_max\n\
dec_min=$dec_min\n\
dec_max=$dec_max\n\

three_ifo_sample_size=$three_ifo_sample_size\n\
two_ifo_sample_size=$two_ifo_sample_size\n\
batch_size=$batch_size #default 1000000\n\
snr_ratio=$snr_ratio\n\
seed=$seed\n\
snr_reference=$snr_reference\n\
snr_uncertainty=$snr_uncertainty\n\
weight_threshold=$weight_threshold\n\

two_ifo_timing_uncertainty=$two_ifo_timing_uncertainty\n\
three_ifo_timing_uncertainty=$three_ifo_timing_uncertainty\n\
two_ifo_smoothing_sigma=$two_ifo_smoothing_sigma\n\
three_ifo_smoothing_sigma=$three_ifo_smoothing_sigma\n\
two_ifo_bin_density=$two_ifo_bin_density #was 4\n\
three_ifo_bin_density=$three_ifo_bin_density #was 2\n\
two_ifo_pb_dtype=$two_ifo_pb_dtype\n\
three_ifo_pb_dtype=$three_ifo_pb_dtype" >> dtdp_${event_name}_${IFOS}.log
