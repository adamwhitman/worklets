#================================================================
# HEADER
#================================================================
#% SYNOPSIS
#%    
#%
#% DESCRIPTION
#%     THis worklet will allow you to rollback Linux packages to the previously installed version.
#% 
#% DISCLAIMER
#%     USE CAUTION WHEN ROLLING BACK LINUX PATCHES AS IT COULD CAUSE THE OS TO BECOME UNRESPONSIVE
#%     Doing full system backup prior to any update is always recommended, and yum history is NOT meant to replace systems backups. 
#%     Be sure to check your distros best practice before rolling back packages
#% 
#% USAGE
#%    EVALUATION VARIABLES
#%    package='<package_name>' : name of the package you want to rollback. This can be retrived from Automox within the software page or device details page.
#%    version='>package_version' : version of the package you want to rollback. This can be retrived from Automox within the software page or device details page.
#%
#%    REMEDIATION VARIABLES
#%    package='<package_name>' : name of the package you want to rollback. This can be retrived from Automox within the software page or device details page.
#%
#% EXAMPLES
#%    package='audit.x86_64' 
#%    version='3.0.7-5.El8'
#% LOGS
#%   /var/log/amagent/rollback_error.log
#================================================================


##EVALUATION

#!/bin/bash

#####user input #####
package='<package_name>'
version='>package_version'


install_check=$(yum list installed | grep -i $package | awk 'NR==1 {print $1}')
version_check=$(yum list installed | grep -i $package | awk 'NR==1 {print$2}')

version_check_lc=$(echo "$version_check" | tr '[:upper:]' '[:lower:]')
version_lc=$(echo "$version" | tr '[:upper:]' '[:lower:]')


if [ "$install_check" = "$package" ] && [ "$version_check_lc" = "$version_lc" ]; then
    #installed and rollback required
    exit 1
else
    #no rollback required
    exit 0
fi



##REMEDIATION

#!/bin/bash
#error logs for the rollback operation
log_file="/var/log/amagent/rollback_error.log"

##### user input #####
package='<package_name>'
##### user input #####

#commands to rollback package
tran_id=$(yum history list | grep -i $package | awk 'NR==1 {print $1}')
yum -y history undo "$tran_id" 2>> "$log_file"

#check to see if package has been uninstalled
installed=$(yum check-update | grep -i $package | awk 'NR==1 {print $1}')

if [ -z $installed ]; then
    echo "Package did not rollback successfully"
else
    echo "Package rollback was successful"
fi
