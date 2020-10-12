#!/bin/bash
# expects IP address as first argument, binary file as second

# Test an IP address for validity:
# Usage:
#      valid_ip IP_ADDRESS
#      if [[ $? -eq 0 ]]; then echo good; else echo bad; fi
#   OR
#      if valid_ip IP_ADDRESS; then echo good; else echo bad; fi
# https://www.linuxjournal.com/content/validating-ip-address-bash-script
function valid_ip()
{
    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

if !(valid_ip "$1")
then
    echo The frist argument expects a valid IP address for the board
    exit 1
fi

read -p "This will overwrite the pattern code, preview, and controls. Are you sure? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
  for f in bin/p/$2
    do
      if [ -e $f ]; then
        FILENAME=$(basename "$f")
        echo "Trying curl -s -i -X POST -H \"Content-Type: multipart/form-data\" -F \"data=@$f;filename=/p/$FILENAME\" \"http://$1/edit\""
        curl -s -i -X POST -H "Content-Type: multipart/form-data" -F "data=@$f;filename=/p/$FILENAME" "http://$1/edit"
        echo "Trying curl -s -i -X POST -H \"Content-Type: multipart/form-data\" -F \"data=@$f.c;filename=/p/$FILENAME.c\" \"http://$1/edit\""
        curl -s -i -X POST -H "Content-Type: multipart/form-data" -F "data=@$f.c;filename=/p/$FILENAME.c" "http://$1/edit"
      else
        echo "Invalid file: $f"
      fi
    done
fi

