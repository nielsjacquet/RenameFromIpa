#!/usr/bin/env bash

##cosmetic functions and Variables
##Colors
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m'
BLUE='\033[0;34m'

##Break function for readabillity
function BR {
  echo "  "
}

##DoubleBreak function for readabillity
function DBR {
  echo " "
  echo " "
}

##Paths
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"  ##Homedir
serverPath="/Volumes/Macintosh HD-1/Users/Shared/myUCB4me_AppRepo"
fileDir="$scriptDir/toRename"
tempFolder="$scriptDir/_TEMP"
payloadFolder="$tempFolder/Payload"


helpFunction()
{
  echo ""
  echo "Usage: $0 -i ipaPath"
  echo -e "\t-i ipaPath -- REQUIRED "
  exitProcedure # Exit script after printing help
}


copyToRenameFolder()
{
  echo Copy the ipa to the to be exploded folder
  cp "$ipaArg" "$fileDir"
}

echo serverPath $serverPath
echo fileDir $fileDir
function ipaCheck {
  for ipasToBeRenamed in "$fileDir"/*
    do
      ipaFileExtentions="${ipasToBeRenamed##*.}"                     ##extract just the FileExtention without the dot
      echo File to be signed: $ipasToBeRenamed
      echo FileExtention: $ipaFileExtentions
      if [ $ipaFileExtentions == "ipa" ]                            ##if the FileExtention equals ipa
        then
          amountOfIpas+=("$ipasToBeRenamed")                         ##put the file in an array
          ipaArrayLength=${#amountOfIpas[@]}                        ##Get the array length for the next statement
        fi
    done
  if [[ $ipaArrayLength < "1" ]]                                    ## if the array length is less than 1, exit the script
   then
    echo no ipa present in the ipas folder: $fileDir
    exit 113                                                        ##exit with code 113
  fi
  }

function getOgIpa {
    printf "${GREEN}Get the og app name${NC}\n"
    for apps in "$fileDir"/*                                             ##for every file in the folder
     do
      ogIpa=$(echo "$(basename "$apps")")                                         ##Get the filename with extention
      printf "${YELLOW}The ipa that will be processed: ${GREEN}$ogIpa${NC}\n"
      unZip
      extractVersion
      extractBundleID
      createName
      renameAndMove
      remove
    done
  }


  function unZip {
    printf "${GREEN}Unzipping the ipa${NC}\n"
    cd "$fileDir"
    unzip "$ogIpa" -d $tempFolder                                                 ##unzip the ipa in a temp folder
  }

  function extractVersion {
    echo "$payloadFolder"
    cd "$payloadFolder"
    payloadApp=$(ls | grep '.app')                                                  ##extract the app version for naming sceme
    infoPlist="$payloadFolder/$payloadApp/info.plist"
    plutil -convert xml1 $infoPlist
    printf "${GREEN}Extracting the app version${NC}\n"
    buildVersionRude=$(cat "$infoPlist" | grep -A1 "CFBundleVersion")
    echo buildVersionRude $buildVersionRude
    buildVersionMinEnd=$(echo ${buildVersionRude%?????????})
    echo buildIDMinEnd: $buildVersionMinEnd
    buildVersionMinFront=$(echo ${buildVersionMinEnd:35})
    echo $buildIDMinFront
    buildVersion=$buildVersionMinFront
  }

  function extractBundleID {                                                      ##extract the app bundleID for naming sceme
    printf "${GREEN}Extracting the bundle id${NC}\n"
    bundleIDRude=$(cat $infoPlist | grep -A1 "CFBundleIdentifier")
    echo bundleIDRude: $bundleIDRude
    bundleIDMinEnd=$(echo ${bundleIDRude%?????????})
    echo bundleIDMinEnd: $bundleIDMinEnd
    bundleIDMinFront=$(echo ${bundleIDMinEnd:38})
    echo bundleIDMinFront: $bundleIDMinFront
    bundleID=$bundleIDMinFront
  }

  function createName {
    newFileName=$bundleID"_"$buildVersion".ipa"
    echo new filename: $newFileName
  }

  function renameAndMove {
    mv $fileDir/"$ogIpa" $scriptDir/$newFileName
    open $scriptDir
  }

  function remove {
    rm -rf $tempFolder
  }

  while getopts "i:?:h:" opt
  do
     case "$opt" in
        i ) ipaArg="$OPTARG" ;;               # Ipa path argument
        ? ) helpFunction ;;                   # Print helpFunction in case parameter is non-existent
        h ) helpFunction ;;                   # Print helpFunction in case parameter is non-existent
     esac
  done

  if [[ -z $ipaArg ]]
    then
      echo ipaArg is empty: $ipaArg
      ipaCheck
      getOgIpa
  fi

  if [[ ! -z $ipaArg  ]]
    then
     echo ipaArg is not empty: $ipaArg
     copyToRenameFolder
     ipaCheck
     getOgIpa
  fi



# ipaCheck
# getOgIpa
