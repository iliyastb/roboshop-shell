#ZONE_ID="Z01272351LK3NIV2TJGOQ"

aws ec2 describe-instances --query "Reservations[*].Instances[*].[PublicIpAddress]" --filters Name=tag:Name,Values=workstation --output text | sed -e 's/"//g'

#sed -e "s/IPADDRESS/${PUB_IP}/" -e "s/DOMAIN/${DOMAIN}/" route53-main.json >/tmp/record.json
#aws route53 change-resource-record-sets --hosted-zone-id ${ZONE_ID} --change-batch file:///tmp/record.json 2>/dev/null