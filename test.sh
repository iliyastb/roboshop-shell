#aws ec2 describe-instances --query "Reservations[*].Instances[*].[PublicIpAddress]" --filters Name=tag:Name,Values=workstation --output text | sed -e 's/"//g'
#--tag-specifications "ResourceType=spot-instances-request,Tags=[{Key=Name,Value=${COMPONENT}}]"
#--instance-market-options "MarketType=spot,SpotOptions={SpotInstanceType=persistent,InstanceInterruptionBehavior=stop}"