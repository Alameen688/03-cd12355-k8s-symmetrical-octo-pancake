#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <CLUSTER_NAME> <AWS_REGION>"
    exit 1
fi

ClusterName=$1
RegionName=$2
FluentBitHttpPort='2020'
FluentBitReadFromHead='Off'

[[ ${FluentBitReadFromHead} = 'On' ]] && FluentBitReadFromTail='Off' || FluentBitReadFromTail='On'
[[ -z ${FluentBitHttpPort} ]] && FluentBitHttpServer='Off' || FluentBitHttpServer='On'
# Fetch and apply the Fluent Bit deployment
curl https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/quickstart/cwagent-fluent-bit-quickstart.yaml | sed "s/{{cluster_name}}/${ClusterName}/;s/{{region_name}}/${RegionName}/;s/{{http_server_toggle}}/${FluentBitHttpServer}/;s/{{http_server_port}}/${FluentBitHttpPort}/;s/{{read_from_head}}/${FluentBitReadFromHead}/;s/{{read_from_tail}}/${FluentBitReadFromTail}/" | kubectl apply -f -

if [ $? -eq 0 ]; then
    echo "Deployment successful!"
    echo "Reminder: Ensure your EKS node role includes the CloudWatchAgentServerPolicy to allow the Fluent Bit agent to properly forward metrics and logs to CloudWatch."
else
    echo "Deployment failed. Please check the error messages above for more details."
fi
