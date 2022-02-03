#! /bin/bash
#
#By QuickOne_Validator - for more info reach me on telegram.
#
#This script will log full validator information on Harmony Blockchain one time per epoch.
#
#To use the script replace Your_ONE_Address_Here with your address.
#
#This script uses hmy tool, the location of the tool must be under the location /home/harmony/hmy
#In case you have a different path, please change the location on all the calls of hmy
#
#You can schedule this script on cron every 5 hours with the scring * */5 * * * /path/to/this/script
#
#Set the path location where you would like to store the files
base_path_location=/home/harmony/
#
#Get current epoch number
current_epoch=$(/home/harmony/hmy --node="https://api.s0.t.hmny.io" blockchain validator information one192wqdhlk84lvxmrd6jl9l9njy7f94q4a3hd87w | grep last-epoch-in-committee | awk 'NR==1 { print$2}' | sed 's/,//')
#
#Determine file location
validator_information_file="$base_path_location"validator_epoch_"$current_epoch".out
#
#Condition if file exists or not, when the file exists no action are needed, when not
#the script with log the validator informaition
 if [ -f "$validator_information_file" ];
  then
   echo -e "File validator_epoch_""$current_epoch"".out exists, no action are needed\nTest run at" $(date) "\n" >>"$base_path_location"validator_information_simple.log
 else
   /home/harmony/hmy --node="https://api.s0.t.hmny.io" blockchain validator information one192wqdhlk84lvxmrd6jl9l9njy7f94q4a3hd87w >>"$base_path_location"validator_epoch_"$current_epoch".out
 fi
