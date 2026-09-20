#!/bin/bash

echo "=========================================="
echo "AWS COST AUDIT - $(date)"
echo "=========================================="

echo ""
echo "--- Running EC2 Instances (default region: $(aws configure get region)) ---"
aws ec2 describe-instances \
  --query "Reservations[].Instances[?State.Name=='running'].{ID:InstanceId,Name:Tags[?Key=='Name']|[0].Value,Type:InstanceType,Launched:LaunchTime}" \
  --output table

echo ""
echo "--- Unused Elastic IPs ---"
aws ec2 describe-addresses \
  --query "Addresses[?InstanceId==null].{IP:PublicIp,AllocationId:AllocationId}" \
  --output table

echo ""
echo "--- Orphaned EBS Volumes (not attached to any instance) ---"
aws ec2 describe-volumes \
  --query "Volumes[?State=='available'].{ID:VolumeId,Size:Size,SizeGB:Size}" \
  --output table

echo ""
echo "--- Running NAT Gateways ---"
aws ec2 describe-nat-gateways \
  --query "NatGateways[?State=='available'].{ID:NatGatewayId,VpcId:VpcId}" \
  --output table

echo ""
echo "--- Load Balancers ---"
aws elbv2 describe-load-balancers \
  --query "LoadBalancers[].{Name:LoadBalancerName,State:State.Code}" \
  --output table

echo ""
echo "=========================================="
echo "Audit complete. Review above for anything"
echo "unexpected, then decide: keep, stop, or"
echo "terminate/delete."
echo "=========================================="
