#!/bin/bash

set -e

cd "${TEXTUAL_WORKSPACE_TEMP_DIR}/Build Headers/"

# Use a unique temp file to avoid races with concurrent builds
_tmpfile="_FeatureFlags_$$.h"

echo "
/* ANY CHANGES TO THIS FILE WILL NOT BE SAVED AND WILL NOT BE COMMITTED */
" > "${_tmpfile}"

featureNames=("TEXTUAL_BUILT_INSIDE_SANDBOX"
			"TEXTUAL_BUILT_WITH_SPARKLE_ENABLED"
			"TEXTUAL_BUILT_WITH_LICENSE_MANAGER"
			"TEXTUAL_BUILT_WITH_ADVANCED_ENCRYPTION"
			"TEXTUAL_BUILT_FOR_APP_STORE_DISTRIBUTION"
			"TEXTUAL_BUILT_AS_UNIVERSAL_BINARY")

for feature in "${featureNames[@]}"; do
	featureValue="${!feature}"

	if [ -n "${featureValue}" ]; then
		echo "#define ${feature} ${featureValue}" >> "${_tmpfile}"
	else
		echo "#define ${feature} 0" >> "${_tmpfile}"
	fi
done

if cmp -s "FeatureFlags.h" "${_tmpfile}"; then
	echo "The feature flags file hasn't changed. Not deploying."
	rm "${_tmpfile}"
else
	# Atomic replace — safe against concurrent builds
	mv -f "${_tmpfile}" "FeatureFlags.h"
fi

# Exit with success
exit 0;
