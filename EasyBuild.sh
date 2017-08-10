#!/bin/bash
#
# s'AVR EasyBuild.sh
#
# Linux shell script to simplify building an s'AVR-Project containing 
# multiple s'AVR source files
#
# written 08/2017 by Ralf Jardon <cosmicos at gmx dot net>
# 
# Requirements: Linux with GNU coreutils, bash and wine!
#
# License: GPLv3
# v0.5

WINE_EXECUTABLE="wine"

SAVR_EXTENSION=".s"
SAVR_ERRORFILE=".err"
SAVR_EXECUTABLE="s'AVR2.23.exe"

N=97                                # ascii code for "a"
AVR_MAINFILE="$1"                   # main file as command line parameter
AVR_COMPILER="avra"                 # avr assembler binary

#
# missing parameter - show help
#

if [ -z $AVR_MAINFILE ]
  then
      echo "Please give a filename for main AVR-file as parameter"
      exit
elif [ -f $AVR_MAINFILE ]           # does file exits?
   then
      echo "$AVR_MAINFILE found! Resume script..."
    else
      echo "$AVR_MAINFILE not found! Stop script"!
      echo
      exit
fi

#
# is the s'AVR executable in workdir?
#

if [ -f $SAVR_EXECUTABLE ]
  then
      echo "$SAVR_EXECUTABLE found! Resume script..."
  else
      echo "$SAVR_EXECUTABLE not found! Stop script!"
      echo
      exit
fi

#
# pre-compile all s'AVR-FILES
#

for SAVR in *$SAVR_EXTENSION ; do

  S_FILENAME=$(basename "$SAVR")                 # build filename for  
                                                 # each sAVR source file
                                                 
  ERR_FILENAME="${S_FILENAME%.*}$SAVR_ERRORFILE" # Filename .err-File
                                                 # if sAVR found an error
  
  SAVR_LABEL=$(printf \\$(printf '%03o' $N))     # build sucsessive label 
                                                 # prefixes
                                             
  ((N++))                                        # next label prefix
    
  echo "Precompiling: $SAVR_EXECUTABLE /$S_FILENAME /label_$SAVR_LABEL"
  $WINE_EXECUTABLE $SAVR_EXECUTABLE /$S_FILENAME /label_$SAVR_LABEL
  
  if [ -f $ERR_FILENAME ]
  then
      echo
      echo "$ERR_FILENAME found! List content:"
      cat $ERR_FILENAME 
      echo "Stop script!"
      echo
      exit
  fi
  
done

#
# assemble AVR MAINFILE
#

echo "Assembling: $AVR_COMPILER $AVR_MAINFILE"

$AVR_COMPILER $AVR_MAINFILE

exit
