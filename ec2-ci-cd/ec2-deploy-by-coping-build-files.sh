PREVIOUS_INSTANCE_NAME=$1
NEW_INSTANCE_NAME=$2

if [ ! -z "$PREVIOUS_INSTANCE_NAME" ]
then
  INSTANCE_ID=`aws ec2 describe-instances --filters "Name=tag:Name,Values=$PREVIOUS_INSTANCE_NAME" --query "Reservations[].Instances[].[InstanceId]" --output text`
  if [ ! -z "$INSTANCE_ID" ]
  then
    echo "Old instance ID: $INSTANCE_ID"
    aws ec2 terminate-instances --instance-ids $INSTANCE_ID
    echo "Terminated the previous instance"
  else
    echo "Did not found any instance with provided name"
  fi
else
  echo "Previous instance name not provided so moving forward"
fi

if [ ! -z "$NEW_INSTANCE_NAME" ]
then
  NEW_INSTANCE_ID=`aws ec2 run-instances --image-id ami-07ffb2f4d65357b42 --count 1 --instance-type t2.micro --key-name CircleCI --security-group-ids sg-0791c0115b3a5100a --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$NEW_INSTANCE_NAME}]" --query "Instances[].[InstanceId]" --output text`
  echo "New instance Id: $NEW_INSTANCE_ID"
  echo "Waiting for New Instance Start...."
  aws ec2 wait instance-running --instance-ids $NEW_INSTANCE_ID
  echo "Instance Successfully started"
  NEW_INSTANCE_IP=`aws ec2 describe-instances --instance-ids $NEW_INSTANCE_ID --query "Reservations[].Instances[].NetworkInterfaces[].Association.PublicIp" --output text`
  echo "New Instance IP: $NEW_INSTANCE_IP"
else
  echo "New Instance Name is Required!"
fi