WORKFLOW_NAME=o2grbs
CONFIG_TAG=v2.3.2.3 # Change as appropriate
GITLAB_URL="https://git.ligo.org/pycbc/offline-analysis/-/raw/${CONFIG_TAG}/production/o4/broad/config"

# Check if the right amount of arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <grb-name> <chunk>"
    exit 1
fi

# Edit for O2 PyNu runs
TYPE=grb
ID=$1
RUNID=

INI_LOC="/home/hannah.griggs/nu/pynu_tests/o2grbs"
STATISTIC_FILE="home/hannah.griggs/nu/pynu_tests/skyloc/dtdphase/L1H1-stat-GRB${ID}.hdf"
#STATISTIC_FILE="${INI_LOC}/chunkinis/H1L1-PHASE_TIME_AMP_O3.hdf"

CHUNK=$2
. /home/hannah.griggs/nu/pynu_tests/o2grbs/chunkinis/config${CHUNK}.ini

# Setting up credentials
USERNAME=$(whoami)
echo "Username = $USERNAME"
echo

# Make sure no proxy is present before creating scitokens and kinit
ecp-get-cert --destroy
htdestroytoken
#ligo-proxy-init $USERNAME
kinit $USERNAME
unset XDG_RUNTIME_DIR
htgettoken -a vault.ligo.org -i igwn --scopes dqsegdb.read,gwdatafind.read,read:/frames,read:/ligo,read:/virgo,read:/kagra
condor_vault_storer -v igwn
export GWDATAFIND_SERVER="datafind.ligo.org:443"
#export _CONDOR_DAGMAN_DEFAULT_APPEND_VARS=True

# Remember to adjust for chunk
PEGASUS_PYTHON=/home/ian.harry/conda_envs/pegasus_python/bin/python PATH=/home/ian.harry/conda_envs/pegasus_python/bin/:${PATH} pycbc_make_offline_search_workflow \
  --workflow-name ${WORKFLOW_NAME} \
  --output-dir output${TYPE}${ID}${RUNID} \
  --config-files \
  ${INI_LOC}/inspiral.ini \
  ${INI_LOC}/analysis_dtdp_noinj.ini \
  ${INI_LOC}/data_O3_C01_clean.ini \
  ${INI_LOC}/gating.ini \
  ${INI_LOC}/executables_common_pynu_noinj.ini \
  ${INI_LOC}/executables_condorpool.ini \
  ${INI_LOC}/gps_times_o3edit.ini \
  ${INI_LOC}/plotting_noinj_noflwup.ini \
  --config-delete \
  --config-overrides \
      results_page:output-path:"/home/${USER}/public_html/pynu/o3/runs/${TYPE}${ID}/${TYPE}${ID}${RUNID}" \
      workflow:start-time:"${GPS_START_TIME}" \
      workflow:end-time:"${GPS_END_TIME}" \
      coinc:statistic-files:"file://localhost/${STATISTIC_FILE} https://git.ligo.org/pycbc/offline-analysis/raw/v2.3.1.0/production/o4/kde_files/TEMPLATE_KDE_PYCBCO4_VERSION1.hdf  https://git.ligo.org/pycbc/offline-analysis/raw/v2.3.1.0/production/o4/kde_files/INJECTION_KDE_PYCBCO4_SNR_GT10_VERSION1.hdf" \
      sngls:statistic-files:"file://localhost/${STATISTIC_FILE} https://git.ligo.org/pycbc/offline-analysis/raw/v2.3.1.0/production/o4/kde_files/TEMPLATE_KDE_PYCBCO4_VERSION1.hdf  https://git.ligo.org/pycbc/offline-analysis/raw/v2.3.1.0/production/o4/kde_files/INJECTION_KDE_PYCBCO4_SNR_GT10_VERSION1.hdf" \
      workflow-tmpltbank:tmpltbank-pregenerated-bank:"/home/hannah.griggs/nu/pynu_tests/o2grbs/chunkinis/H1L1-BANK2HDF-O2.hdf" \
      workflow-segments:segments-veto-definer-url:"https://git.ligo.org/detchar/veto-definitions/raw/65588104ed552713d059ef9f459d4d3cdab83ec8/cbc/O2/H1L1-CBC_VETO_DEFINER_CLEANED_C02_O2_1164556817-23176801.xml" \
      workflow:gating-method:"PREGENERATED_FILE" \
      workflow:gating-file-h1:"https://git.ligo.org/detchar/veto-definitions/-/raw/master/cbc/O2/H1-GATES-1163203217-24537601.txt" \
      workflow:gating-file-l1:"https://git.ligo.org/detchar/veto-definitions/-/raw/master/cbc/O2/L1-GATES-1163203217-24537601.txt" \
      workflow:h1-channel-name:"H1:DCH-CLEAN_STRAIN_C02" \
      workflow:l1-channel-name:"L1:DCH-CLEAN_STRAIN_C02" \
      workflow-datafind:datafind-h1-frame-type:"H1_CLEANED_HOFT_C02" \
      workflow-datafind:datafind-l1-frame-type:"L1_CLEANED_HOFT_C02" \
      workflow-segments-h1:segments-science:"+DCH-CLEAN_SCIENCE_C02:1" \
      workflow-segments-l1:segments-science:"+DCH-CLEAN_SCIENCE_C02:1" \
  --cache-file maps/chunk${CHUNK}.map \
  --submit-now
