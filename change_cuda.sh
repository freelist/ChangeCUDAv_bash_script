#!/bin/sh
#sudo rm -rf /usr/local/cuda
#sudo ln -s /usr/local/cuda-$1.0 /usr/local/cuda
shopt -s extglob nullglob

basedir=/usr/local

# You may omit the following subdirectories
# the syntax is that of extended globs, e.g.,
# omitdir="cmmdm|not_this_+([[:digit:]])|keep_away*"
# If you don't want to omit any subdirectories, leave empty: omitdir=
acceptdir="cuda-*"

# Create array
cdarray=( "$basedir"/$acceptdir/ )

# remove leading basedir:
cdarray=( "${cdarray[@]#"$basedir/"}" )
# remove trailing backslash and insert Exit choice
cdarray=( Exit "${cdarray[@]%/}" )

# At this point you have a nice array cdarray, indexed from 0 (for Exit)
# that contains Exit and all the subdirectories of $basedir
# (except the omitted ones)
# You should check that you have at least one directory in there:
if ((${#cdarray[@]}<=1)); then
    printf 'No subdirectories found. Exiting.\n'
    exit 0
fi

# Read current cuda version
linktarget=$(readlink -f /usr/local/cuda)
linktargetresult=$(echo $linktarget | grep -oE "[^//]+$")

# Display the menu:
printf 'Please choose from the following. Enter 0 to exit.\n'
for i in "${!cdarray[@]}"; do
    if [ "${cdarray[i]}" == "$linktargetresult" ]; then
      printf '   %d %s (current)\n' "$i" "${cdarray[i]}"
    else
      printf '   %d %s\n' "$i" "${cdarray[i]}"
    fi
done
printf '\n'

# Now wait for user input
while true; do
    read -e -r -p 'Your choice: ' choice
    # Check that user's choice is a valid number
    if [[ $choice = +([[:digit:]]) ]]; then
        # Force the number to be interpreted in radix 10
        ((choice=10#$choice))
        # Check that choice is a valid choice
        ((choice<${#cdarray[@]})) && break
    fi
    printf 'Invalid choice, please start again.\n'
done

# At this point, you're sure the variable choice contains
# a valid choice.
if ((choice==0)); then
    printf 'Good bye.\n'
    exit 0
fi

## Now you can work with subdirectory:
# Switch cuda version
sudo rm -rf /usr/local/cuda
sudo ln -s /usr/local/${cdarray[choice]} /usr/local/cuda
# Say goodbye
printf "Your newly selected cuda version: \`%s'.\n" "${cdarray[choice]}"
