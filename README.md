# Kubernetes Pod Matching Script and Deployment Definition

I made it because it was helpful for me to learn
This repository contains a Bash script and a Deployment definition for Kubernetes clusters, which assigns pending pods to a specific custom scheduler and then binds them to a random node.

## Usage

### 1. Apply the Deployment Definition

First, apply the Deployment definition in the `nginx-deployment.yaml` file to your Kubernetes cluster:

kubectl apply -f nginx-deployment.yaml

This will create a Deployment named nginx and activate 3 replicas.

### 2. Run the Matching Script

Next, run the Bash script named `scheduler.sh` to initiate the pod matching process. The script will check pending pods and bind those assigned to a specific scheduler to a random node.

./scheduler.sh

After running the script, a loop will start where pending pods are continuously monitored and assigned to an appropriate node.

## Custom Settings

Before running the script, you can customize some variables:

- `SERVER`: Address and port of the Kubernetes API server. By default, it's set to `localhost:8001`.
- `SCHEDULER`: Name of the custom scheduler to which pods will be assigned. By default, it's set to `myCustomScheduler`.
- `SLEEP_INTERVAL`: Time interval the script will wait after pod assignment. By default, it's set to `9s`.

You can update these variables at the beginning of the script.

## Notes

- This script and Deployment definition are designed for learning and testing purposes only. Ensure thorough testing before using them in real production environments.
- The script requires tools like `kubectl` and `curl`. Make sure these tools are installed on your system.

