#! /bin/bash
#Script to restart harmony service if it is noticed that the system is not signing
#Created by QuickOne_Validator

#Creating a log file
echo "Script run at:" $(date) >> /home/harmony/log_signature_check_$(date +"%Y_%m_%d").log

#Getting the number of blocks requested to be signed
to_sign_first_check=$(/home/harmony/hmy --node="https://api.s0.t.hmny.io" blockchain validator information one192wqdhlk84lvxmrd6jl9l9njy7f94q4a3hd87w | grep current-epoch-to-sign | awk 'NR==1 { print$2}' | sed 's/,//') 

#Dumping the result on the log file as well on a dat file
echo "On the first check requested to sign are:" $to_sign_first_check >> /home/harmony/log_signature_check_$(date +"%Y_%m_%d").log
echo $to_sign_first_check > /home/harmony/to_sign_first_check.dat

#Getting the number of blocks signed
signed_first_check=$(/home/harmony/hmy --node="https://api.s0.t.hmny.io" blockchain validator information one192wqdhlk84lvxmrd6jl9l9njy7f94q4a3hd87w | grep current-epoch-signed | awk 'NR==1 { print$2}' | sed 's/,//')

#Dumping the result on the log file and on a dat file
echo "On the first check there were signed: " $signed_first_check >> /home/harmony/log_signature_check_$(date +"%Y_%m_%d").log
echo $signed_first_check > /home/harmony/signed_first_check.dat
first_signed_difference=$((to_sign_first_check - signed_first_check))
Golden_File=/home/harmony/to_sign_golden_reference.dat
    if [ -f "$Golden_File" ]; then
        golden_value=`cat /home/harmony/to_sign_golden_reference.dat`
               if [ $first_signed_difference -eq $golden_value ]; then
                   echo "*#*#*#*#*#*#*#*" >> /home/harmony/log_signature_check_$(date +"%Y_%m_%d").log
                   echo "Difference matches the Golden value, no need to continue " $first_signed_difference>> /home/harmony/log_signature_check_$(date +"%Y_%m_%d").log
                   echo "No action are needed at this time.">> /home/harmony/log_signature_check_$(date +"%Y_%m_%d").log
                   echo "*#*#*#*#*#*#*#*" >> /home/harmony/log_signature_check_$(date +"%Y_%m_%d").log
                   echo -e "\n\n" >> /home/harmony/log_signature_check_$(date +"%Y_%m_%d").log
                   exit
               fi
   fi
#Checking the difference, if different from zero take further actions.
if [ $to_sign_first_check -ge $signed_first_check ]; then
            first_signed_difference=$((to_sign_first_check - signed_first_check))
            echo "First difference: " $first_signed_difference>> /home/harmony/log_signature_check_$(date +"%Y_%m_%d").log
            sleep 60
            #Getting the number of blocks requested to be signed after 1 minute
            to_sign_second_check=$(/home/harmony/hmy --node="https://api.s0.t.hmny.io" blockchain validator information one192wqdhlk84lvxmrd6jl9l9njy7f94q4a3hd87w | grep current-epoch-to-sign | awk 'NR==1 { print$2}' | sed 's/,//') 
            
            #Dumping the result on the log file as well on a dat file
            echo "On the second check requested to sign are:" $to_sign_second_check >> /home/harmony/log_signature_check_$(date +"%Y_%m_%d").log
            echo $to_sign_second_check > /home/harmony/to_sign_second_check.dat
            
            #Getting the number of blocks signed
            signed_second_check=$(/home/harmony/hmy --node="https://api.s0.t.hmny.io" blockchain validator information one192wqdhlk84lvxmrd6jl9l9njy7f94q4a3hd87w | grep current-epoch-signed | awk 'NR==1 { print$2}' | sed 's/,//')
            
            #Dumping the result on the log file and on a dat file
            echo "On the second check there were signed: " $signed_second_check >> /home/harmony/log_signature_check_$(date +"%Y_%m_%d").log
            echo $signed_second_check > /home/harmony/signed_second_check.dat
            second_signed_difference=$((to_sign_second_check - signed_second_check))
            
            if [$first_signed_difference -eq $second_signed_difference ]; then
            echo $first_signed_difference > /home/harmony/to_sign_golden_reference.dat
            fi
            
            echo "Second difference: " $second_signed_difference>> /home/harmony/log_signature_check_$(date +"%Y_%m_%d").log
            total_difference=$((second_signed_difference - first_signed_difference))
                    if [ $total_difference -ge 5 ]; then   
                    FILE=/home/harmony/restart_number_$(date +"%Y_%m_%d_%H").dat
                          if [ -f "$FILE" ]; then
                                restart_times=`cat /home/harmony/restart_number_$(date +"%Y_%m_%d_%H")`
                                      if [ $restart_times -lt 6 ]; then
                                      echo "Harmony service restarted on: " $(date)>> /home/harmony/log_signature_check_$(date +"%Y_%m_%d").log
                                      sudo systemctl restart harmony.service
                                      restart_times=$((restart_times+1))
                                      echo $restart_times > /home/harmony/restart_number_$(date +"%Y_%m_%d_%H").dat
                                      fi
                            else 
                                echo 1 > /home/harmony/restart_number_$(date +"%Y_%m_%d_%H").dat
                                #Remove old file
                                rm -f /home/harmony/restart_number_$(date -d '1 hour ago' +"%Y_%m_%d_%H").dat
                                 echo -e "**********************************************************************" >> /home/harmony/log_signature_check_$(date +"%Y_%m_%d").log
                                echo "Harmony service restarted on: " $(date)>> /home/harmony/log_signature_check_$(date +"%Y_%m_%d").log
                                 echo -e "\n\n" >> /home/harmony/log_signature_check_$(date +"%Y_%m_%d").log
                                sudo systemctl restart harmony.service
                                echo -e "**********************************************************************" >> /home/harmony/log_signature_check_$(date +"%Y_%m_%d").log
                                fi              
                else
                      echo "Total difference: " $total_difference>> /home/harmony/log_signature_check_$(date +"%Y_%m_%d").log
                      echo "No action are needed at this time.">> /home/harmony/log_signature_check_$(date +"%Y_%m_%d").log
                      echo -e "\n\n" >> /home/harmony/log_signature_check_$(date +"%Y_%m_%d").log
                fi
                
fi
EOF
