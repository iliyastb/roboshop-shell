ZONE_ID="Z01272351LK3NIV2TJGOQ"
DOMAIN="devtb.online"
SG_NAME="allow-all"
COMPONENT="frontend"

create_ec2() {
  echo -e '#!/bin/bash' >/tmp/user-data
  echo -e "\nset-hostname ${COMPONENT}" >>/tmp/user-data
  PUBLIC_IP=$(aws ec2 run-instances \
      --image-id "${AMI_ID}" \
      --instance-type t2.micro \
      --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${COMPONENT}}, {Key=Monitor,Value=yes}]" \
      --security-group-ids "${SGID}" \
      --user-data file:///tmp/user-data)

  sed -e "s/IPADDRESS/${PUB_IP}/" -e "s/COMPONENT/${COMPONENT}/" -e "s/DOMAIN/${DOMAIN}/" route53-main.json >/tmp/record1.json
  aws route53 change-resource-record-sets --hosted-zone-id ${ZONE_ID} --change-batch file:///tmp/record1.json 2>/dev/null

  if [ $? -eq 0 ]; then
    echo "Server Created - SUCCESS - DNS RECORD - ${DOMAIN}"
  else
    echo "Server Created - FAILED - DNS RECORD - ${DOMAIN}"
    exit 1
  fi
}

PUB_IP=$(aws ec2 describe-instances --query "Reservations[*].Instances[*].[PublicIpAddress]" --filters Name=instance-state-name,Values=running --output text | sed -e 's/"//g')
if [ -z "${PUB_IP}" ]; then
  echo "IP not found"
  exit 1
fi

AMI_ID=$(aws ec2 describe-images --filters "Name=name,Values=Centos-8-DevOps-Practice" | jq '.Images[].ImageId' | sed -e 's/"//g')
if [ -z "${AMI_ID}" ]; then
  echo "AMI_ID not found"
  exit 1
fi

SGID=$(aws ec2 describe-security-groups --filters Name=group-name,Values=${SG_NAME} | jq '.SecurityGroups[].GroupId' | sed -e 's/"//g')
if [ -z "${SGID}" ]; then
  echo "Given Security Group does not exit"
  exit 1
fi

create_ec2