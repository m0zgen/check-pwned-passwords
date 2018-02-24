#!/bin/bash
# Created by Yevgeniy Goncharov - https://sys-adm.in
# Script for downloading and checking Pwned passwords
#
# https://haveibeenpwned.com/Passwords
# https://downloads.pwnedpasswords.com/passwords/pwned-passwords-2.0.txt.7z
# https://downloads.pwnedpasswords.com/passwords/pwned-passwords-1.0.txt.7z
# https://downloads.pwnedpasswords.com/passwords/pwned-passwords-update-1.txt.7z
# https://downloads.pwnedpasswords.com/passwords/pwned-passwords-update-2.txt.7z
#

cat << "EOF"
 _            _   _  _          _
/ |_  _  _|__/ \_|__|_|o._  ___|_)  ._  _  _|
\_| |(/_(_|< \_/ |  | ||| |(/_ |\/\/| |(/_(_|
                                         v1.1

EOF

PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
SCRIPT_PATH=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)

RED='\033[1;31m'
GREEN='\033[1;32m'
CL='\033[0m'

CHECK_PASSWORDS=false
PASSWORDS="pwned-passwords-2.0.txt.7z pwned-passwords-1.0.txt.7z pwned-passwords-update-1.txt.7z pwned-passwords-update-2.txt.7z"

# Chech downloaded databases?
echo -en "\n${GREEN}Check pawned database for download (y${CL}/${RED}n${CL})? You can press Enter for skip. "
read answer

if echo "$answer" | grep -iq "^y" ;then
  CHECK_PASSWORDS=true
fi

# If check True - check and download
if [ "$CHECK_PASSWORDS" == true ]; then

  # Check downloaded versions
  for f in $PASSWORDS; do
    if [ ! -f $SCRIPT_PATH/$f ]; then
      echo -e "File $SCRIPT_PATH/$f ${RED}not found!${CL}"

      # Download?
      echo -en "${GREEN}Download (y${CL}/${RED}n${CL})? "
      read answer
      if echo "$answer" | grep -iq "^y" ;then
        echo "Get file $f"

        # Download
        wget -O "$SCRIPT_PATH/$f" "https://downloads.pwnedpasswords.com/passwords/$f"
        # Unpack
        7z -o/mnt/dta4/pwd x "$SCRIPT_PATH/$f"

      fi
    else
      echo -e "File $SCRIPT_PATH/$f ${GREEN}already downloaded!${CL}"
    fi
  done
fi

# Enter you password
echo "Please enter your password for checking:"
read -s pw

# Check entered password
if [[ "$pw" == "" ]]; then
    echo -e "You must enter password. Bye!"
    exit 1
  else

    # Convert to hash
    PW_HASH=$(echo -n "$pw"| sha1sum | sed 's/ .*$//' | tr a-z A-Z)
    # Check hash in the pawned database
    for p in $PASSWORDS; do
      p_file=$(echo $p | sed 's/\(.*\)\.7z/\1/')

      echo -e "\nCheck: $p_file"
      if  egrep -q "$PW_HASH" $SCRIPT_PATH/$p_file > /dev/null ; then
        echo -e "${RED}You password $pw - compromised!${CL}"
      else
        echo -e "${GREEN}Wow - you password not found!${CL}"
      fi
    done
fi

echo ""

# Re-run script or exit
new=$(readlink -f "$0")
while true; do
  read -p "Do you wish to run Check-Pass again?[y/n]: " yn
  case $yn in
    [Yy]* ) printf "\033c" && exec "$new"; break;;
    [Nn]* ) printf "\033c" && exit;;
      * ) printf "Please answer yes or no.\n";;
      esac
done