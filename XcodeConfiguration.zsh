#!/bin/zsh

# Lots of this code came from - https://www.jamf.com/jamf-nation/discussions/26615/xcode-9-2-deployment
# I added logging so we can see what happened after runnning this
# Also converted from bash to zsh, mostly changed if statements
# Also added CodeTypes.pkg install for Xcode version 13.2.1
# Lynna Jackson, April 2022

# Create log file 
mkdir -p /Library/Logs/Xcode/
touch /Library/Logs/Xcode/XCodeInstall.log
# Close standard output
exec 1<&-
# Close error output
exec 2<&-
# Open log file above for read and write
exec 1<>/Library/Logs/Xcode/XCodeInstall.log
# Redirect all output to log file above
exec 2>&1

echo "Script started: Xcode Configure at  $(date)"
echo " ------- "

# Accept EULA so there is no prompt
if [[ -e "/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild" ]] 
then
  echo " ------- "  
  echo "First license accepted at:  $(date)"
  "/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild" -license accept  
fi

# Just in case the xcodebuild command above fails to accept the EULA, set the license acceptance info 
# in /Library/Preferences/com.apple.dt.Xcode.plist. For more details on this, see Tim Sutton's post: 
# http://macops.ca/deploying-xcode-the-trick-with-accepting-license-agreements/
if [[ -e "/Applications/Xcode.app/Contents/Resources/LicenseInfo.plist" ]] 
then
   xcode_version_number=`/usr/bin/defaults read "/Applications/Xcode.app/Contents/"Info CFBundleShortVersionString`
   xcode_build_number=`/usr/bin/defaults read "/Applications/Xcode.app/Contents/Resources/"LicenseInfo licenseID`
   xcode_license_type=`/usr/bin/defaults read "/Applications/Xcode.app/Contents/Resources/"LicenseInfo licenseType`
   echo " ------- "
   echo "Second license accepted at:  $(date)"
   echo "$xcode_version_number"
   echo "$xcode_build_number"
   echo "$xcode_license_type"   
   
   if [[ "${xcode_license_type}" == "GM" ]] 
   then
       /usr/bin/defaults write "/Library/Preferences/"com.apple.dt.Xcode IDEXcodeVersionForAgreedToGMLicense "$xcode_version_number"
       /usr/bin/defaults write "/Library/Preferences/"com.apple.dt.Xcode IDELastGMLicenseAgreedTo "$xcode_build_number"
    else
       /usr/bin/defaults write "/Library/Preferences/"com.apple.dt.Xcode IDEXcodeVersionForAgreedToBetaLicense "$xcode_version_number"
       /usr/bin/defaults write "/Library/Preferences/"com.apple.dt.Xcode IDELastBetaLicenseAgreedTo "$xcode_build_number"
   fi       
fi

# DevToolsSecurity tool to change the authorization policies, such that a user who is a
# member of either the admin group or the _developer group does not need to enter an additional
# password to use the Apple-code-signed debugger or performance analysis tools.
echo " ------- "
echo "DevToolsSecurity enabled at:  $(date)"
/usr/sbin/DevToolsSecurity -enable

# Add all users to developer group, if they're not admins
echo " ------- "
echo "All Users add to developer group at:  $(date)"
/usr/sbin/dseditgroup -o edit -a everyone -t group _developer


# If you have multiple versions of Xcode installed, specify which one you want to be current.
echo " ------- "
echo "Setting /Applications/Xcode as current Xcode at:  $(date)"
/usr/bin/xcode-select --switch /Applications/Xcode.app

# Bypass Gatekeeper verification for Xcode, which can take hours.
if [[ -e "/Applications/Xcode.app" ]]; then 
  echo " ------- "
  echo "Remove Gatekeeper's quaratine bit at:  $(date)"
  xattr -dr com.apple.quarantine /Applications/Xcode.app
fi

# Enable first run items
if [ -e "/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild" ]; then
	for PKG in $(/usr/bin/find "/Applications/Xcode.app/Contents/Resources/Packages" -name "*.pkg"); do
    	/bin/echo "Installing resource package: $PKG"
    	/usr/sbin/installer -pkg "$PKG" -target /
        /bin/echo "Installation for \"$PKG\" complete"
	done
else
	/bin/echo "Error: Xcode does not appear to be installed on this system."
    exit 1
fi

# Set sleep timers back to 45 minutes
echo " ------- "
echo "Setting sleep timers back to 45 minutes at $(date)"
pmset -a sleep 45
pmset -a disksleep 45
pmset -a displaysleep 45

# Run Jamf inventory to record Xcode installed and drop mac out of smart group for install
echo " ------- "
echo "Running Jamf Inventory at $(date)"
jamf recon

echo " ------- "
echo "Script ended: Xcode Configure at  $(date)"
echo " ------- "