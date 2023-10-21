#aws ec2 describe-instances --query "Reservations[*].Instances[*].[PublicIpAddress]" --filters Name=tag:Name,Values=workstation --output text | sed -e 's/"//g'
#--tag-specifications "ResourceType=spot-instances-request,Tags=[{Key=Name,Value=${COMPONENT}}]"
#--instance-market-options "MarketType=spot,SpotOptions={SpotInstanceType=persistent,InstanceInterruptionBehavior=stop}"

ZONE_ID="Z01272351LK3NIV2TJGOQ"
DOMAIN="devtb.online"

PUBLIC_IP=$(aws ec2 describe-instances --query "Reservations[*].Instances[*].[PublicIpAddress]" --filters Name=tag:Name,Values=frontend --output text)
sed -e "s/IPADDRESS/${PUBLIC_IP}/" -e "s/DOMAIN/${DOMAIN}/" route53-main.json >/tmp/record.json
aws route53 change-resource-record-sets --hosted-zone-id ${ZONE_ID} --change-batch file:///tmp/record.json 2>/dev/null