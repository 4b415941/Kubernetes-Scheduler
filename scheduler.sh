#!/usr/bin/env bash

# This script assigns pending Kubernetes pods to a random node if assigned to a specific scheduler.

set -eo pipefail

# Default server and scheduler names to be used
SERVER="${SERVER:-localhost:8001}"
SCHEDULER="${SCHEDULER:-myCustomScheduler}"

# Sleep interval after pod assignment for waitin
SLEEP_INTERVAL="9s"

# Function to assign a specific pod to a specific node
assign_pod_to_node(){
    local pod=$1
    local namespace=$2
    local node=$3

    local response
    # Sending request to Kubernetes API
    response=$(curl --silent --fail --header "Content-Type: application/json" --request POST \
                   --data "{\"apiVersion\":\"v1\",\"kind\": \"Binding\",\"metadata\": {\"name\": \"$pod\"},\"target\": {\"apiVersion\": \"v1\",\"kind\": \"Node\",\"name\": \"$node\"}}" \
                   "http://$SERVER/api/v1/namespaces/$namespace/pods/$pod/binding/")

    # Checking if the operation was successful or not
    if [[ "$response" == *"\"code\": 201"* ]]; then
        echo "Assigned $pod to $node"
    else
        echo "Failed to assign $pod to $node"
    fi
}

while true; do
    echo "Checking for pending pods..."
    pending_pods=$(kubectl --server "$SERVER" get pods --output jsonpath='{range .items[?(@.status.phase=="Pending")]}{.metadata.name} {.metadata.namespace} {.spec.schedulerName}{"\n"}{end}')

    # Process each pending pod
    while IFS= read -r line; do
        read -r pod namespace scheduler <<<"$line"

        # If pod is assigned to a specific scheduler
        if [[ "$scheduler" == "$SCHEDULER" ]]; then
            echo "Found pending pod: $pod in namespace: $namespace"
            
            # Get all the nodes
            nodes=($(kubectl --server "$SERVER" get nodes --output jsonpath='{.items[*].metadata.name}'))
            if [ "${#nodes[@]}" -gt 0 ]; then
                random_node=${nodes[$RANDOM % ${#nodes[@]}]}
            else
                echo "No nodes available!"
            fi
            # Assign the pod to the node
            assign_pod_to_node "$pod" "$namespace" "$random_node"
        fi
    done <<<"$pending_pods"

    # Sleep for a certain interval
    echo "Sleeping for $SLEEP_INTERVAL"
    sleep "$SLEEP_INTERVAL"
done
