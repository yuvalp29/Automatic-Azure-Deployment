#!/bin/sh

# Just to notice:
# $1 = VM_TYPE
# $2 = VM_MAME
# $3 = VM_SIZE

IFS=$'\n' 
read -d '' -r -a lines < ./txtFiles/Parameters.txt

$1="${lines[0]}"
$2="${lines[1]}"
$3="${lines[2]}"