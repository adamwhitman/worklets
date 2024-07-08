#EVALUATION

#!/bin/bash

#================================================================
# HEADER
#================================================================
# SYNOPSIS
#   macOS - Software Lifecycle - Automox AgentUI Install and Opt in
#
# DESCRIPTION
#   This worklet will opt in the endpoint to receive AgentUI.
#
# USAGE
#   ./evaluation.sh
#
#================================================================
# IMPLEMENTATION
#   version         CABBIT-1028_macOS_AgentUI_deployment (www.automox.com) 1.0
#   author          Matt Bauer
#
#================================================================
# HISTORY
#   04/16/2024 : ax-mbauer : Worklet Created
#
#================================================================
# END_OF_HEADER
#================================================================

if [[ -d "/Library/Application Support/Automox/AgentUI.app" ]]; then
    echo "Automox AgentUI already installed, endpoint opted in to receive future UI updates."
    exit 0
else
    echo "Automox AgentUI not installed, remediation will be scheduled."
    exit 1
fi



#REMEDIATION

#!/bin/bash

#================================================================
# HEADER
#================================================================
# SYNOPSIS
#   macOS - Software Lifecycle - Automox AgentUI Install and Opt in
#
# DESCRIPTION
#   This worklet will opt in the endpoint to receive AgentUI.
#
# USAGE
#   ./remediation.sh
#
#================================================================
# IMPLEMENTATION
#   version         CABBIT-1028_macOS_AgentUI_deployment (www.automox.com) 1.0
#   author          Matt Bauer
#
#================================================================
# HISTORY
#   04/16/2024 : ax-mbauer : Worklet Created
#
#================================================================
# END_OF_HEADER
#================================================================

downloadURL="https://api.automox.com/api/cache?cmd=downloadLatestVersion&name=AgentUI&os=Mac&arch=64"
tempDir=$(mktemp -d /tmp/XXXXXX)

function fail {
    echo "Error: $1"
    rm -rf "${tempDir}"
    exit 1
}

if [[ -d "/Library/Application Support/Automox/AgentUI.app" ]]; then
    fail "Automox AgentUI already installed. Exiting"
else
    echo "Opted-in device or AgentUI install detected, proceeding..."
    pushd "${tempDir}" &>/dev/null || fail "Failed to switch to temporary directory."
    if ! curl -sSLf -o "${tempDir}/AutomoxAgentUI.pkg" "${downloadURL}"; then
        fail "Failed to download AgentUI. Cleaning up and exiting..."
    else
        if [[ -z "$(find . -name "AutomoxAgentUI.pkg" -exec basename {} \; -quit)" ]]; then
            fail "Installer not found in temp directory. Cleaning up and exiting..."
        fi
    fi
fi

echo "Installing AgentUI..."
installer -tgt / -pkg AutomoxAgentUI.pkg 2>&1
if [[ "${PIPESTATUS[0]}" != 0 ]]; then
    fail "Package installation failed"
else
    rm -rf "${tempDir}"
    agentUIVersion="$(defaults read /Library/Application\ Support/Automox/AgentUI.app/Contents/Info.plist CFBundleShortVersionString)"
    echo "Automox AgentUI version ${agentUIVersion} installed. Exiting..."
fi

exit
