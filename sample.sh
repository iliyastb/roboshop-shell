aws ec2 describe-instances --query "Reservations[*].Instances[*].[PublicIpAddress]" --filters "Monitor=yes" --output text | sed -e 's/"//g'