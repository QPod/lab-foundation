PROFILE_LOCALIZE=${PROFILE_LOCALIZE:-"default"}
echo "Using PROFILE_LOCALIZE=${PROFILE_LOCALIZE}"

source /opt/utils/localize/run-config-mirror-${PROFILE_LOCALIZE}.sh
