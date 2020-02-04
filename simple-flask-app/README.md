## Notes

This is a simple flask app which purpose is to create tweets with funny memes and wise quotes. 

## Deployment

The application has a Dockerfile and a Helm chart for Kubernetes deployments as we used in the demo. 

In order to get it up and running in Kubernetes you must first setup Jenkins and Helm on your cluster or you can install it manually.

> helm upgrade --install python-app python-app --namespace demo