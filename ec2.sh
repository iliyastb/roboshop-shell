ZONE_ID="Z01272351LK3NIV2TJGOQ"
SG_NAME="allow-all"

AMI_ID=$(aws ec2 describe-images --filters "Name=name,Values=Centos-8-DevOps-Practice" | jq '.Images[].ImageId' | sed -e 's/"//g')
if [ -z "${AMI_ID}" ]; then
  echo "AMI_ID not found"
  exit 1
fi

SGID=$(aws ec2 describe-security-groups --filters Name=group-name,Values=${SG_NAME} | jq  '.SecurityGroups[].GroupId' | sed -e 's/"//g')
if [ -z "${SGID}" ]; then
  echo "Given Security Group does not exit"
  exit 1
fi

create_ec2_main() {
  echo -e '#!/bin/bash' >/tmp/user-data
  echo -e "\nset-hostname frontend" >>/tmp/user-data
  PUBLIC_IP=$(aws ec2 run-instances \
      --image-id ${AMI_ID} \
      --instance-type t2.micro \
      --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=frontend}, {Key=Monitor,Value=yes}]" \
      --security-group-ids ${SGID} \
      --user-data file:///tmp/user-data \
      | jq '.Instances[].PrivateIpAddress' | sed -e 's/"//g')

  sed -e "s/IPADDRESS/${PUBLIC_IP}/" -e "s/COMPONENT/frontend/" -e "s/DOMAIN/devtb.online/" route53-main.json >/tmp/record.json
  aws route53 change-resource-record-sets --hosted-zone-id ${ZONE_ID} --change-batch file:///tmp/record.json 2>/dev/null

  if [ $? -eq 0 ]; then
    echo "Server Created - SUCCESS - DNS RECORD - devtb.online"
  else
     echo "Server Created - FAILED - DNS RECORD - devtb.online"
     exit 1
  fi
}