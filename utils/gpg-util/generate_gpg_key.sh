#!/bin/bash
# Generate gpg2 keys for password encryption. On command line, type:
# gpg2 --gen-key
# Follow prompts:
#   Real name:		    <First Last Name>
#   Email address:	    email.address@email.com
#   Change (N), Email(E) or Okay(O)/Quit(Q): O
#   Enter Passphrase:	    <Create GPG Password>

# To store passwords in a new password keystore, install 'pass'
# sudo apt-get install pass

# To initialize new password keystore:
# pass init "Joe-Schmoe's Password Registry"

# Insert new password into keystore:
# pass insert <account-name>

# Get GPG2 Id, needed to specify which encryption key to use for your password
get_gpg_id () {
    response=$(gpg2 --list-secret-keys --keyid-format=long)
    gpg_id=$( echo "$response" | grep "sec" | grep -oP '(?<=/).*?(?= )')
}

check_gpg_id () {
    get_gpg_id 
    
    if [ -z $gpg_id ]; then
        read -p "No value for gpg_id. Create One? (y/n):" yn
    
        while true; do
            case $yn in 
                [yY] ) 
                    echo " Follow prompts:
                        Real name:		    <First Last>
                        Email address:	    sbish33@gmail.com
                        Change (N), Email(E) or Okay(O)/Quit(Q): O
                        Enter Passphrase:	    <Enter a GPG Password>"
                    gpg2 --gen-key;
                    get_gpg_id
                    break;;
    
                [nN] ) echo "exiting...";
                    exit;;
    
                * ) echo invalid response;;
            esac
        done
    fi

}

echo "Running gpg key gen"

gpg_keypath="/home/ubuntu/.gnupg/private-keys-v1.d"

# Initialize Password Store
if [ -z $gpg_keypath ]; then
    echo "No value for gpg_keypath!"
    exit 1
else
    echo "gpg_keypath is: $gpg_keypath"
fi

check_gpg_id

echo "gpg_id is: $gpg_id"
#pass init -p $gpg_keypath $gpg_id
pass init $gpg_id

# Insert password for registry1 account. Follow Prompts.
exec pass insert registry1
