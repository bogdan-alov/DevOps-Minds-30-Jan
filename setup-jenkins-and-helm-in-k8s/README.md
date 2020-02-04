## Notes

In order to get helm up and running in kubernetes you must first apply the resources.yaml file . This will create Kubernetes resources

> kubectl apply -f resources.yaml

After that initialize helm with the following command:

> helm init --service-account tiller

This will initialize helm on a global scale in your cluster which is not a very wise decision. For a small project you can use it like this but it is better to have it in a separate namespace. You can achieve that with the following command:

> helm init --service-account tiller --tiller-namespace <your-namespace>

Like that you won't need to pass tiller admin rights to your whole cluster and can limit it to the namespace.

After you setup helm, you can proceed with installing Jenkins. 

> helm install --name my-release stable/jenkins --namespace jenkins-cicd

This will pick the Jenkins Helm chart from the official helm charts and install it to the previously created namespace - jenkins-cicd. You can find more info about offical helm chart [HERE](https://github.com/helm/charts/tree/master/stable/jenkins) .

There is also a Jenkinsfile that could be integrated with your Jenkins instance and start deploying. :) 