PROFILE_LOCALIZE=${PROFILE_LOCALIZE:-"default"}
echo "Using PROFILE_LOCALIZE=${PROFILE_LOCALIZE}"

# Define the file path based on the PROFILE_LOCALIZE variable
# reference: https://github.com/RubyMetric/chsrc/blob/main/src/chsrc.c
FILE="/opt/utils/localize/run-config-mirror-${PROFILE_LOCALIZE}.sh"

# Check if the file exists
if [ -f "$FILE" ]; then
    . "$FILE"
else
    echo "No such profile for localize: $PROFILE_LOCALIZE"
fi
