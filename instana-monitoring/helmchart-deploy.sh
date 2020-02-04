helm install --name instana-agent --namespace instana-agent \
--set agent.key={agent key} \
--set agent.endpointHost={saas or onprem Instana endpoint} \
--set agent.endpointPort={port} \
--set zone.name=K8s-cluster \
stable/instana-agent
