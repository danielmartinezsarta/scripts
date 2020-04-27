# Scripts para creación y gestión de VM en Azure

* ### Creacion de grupo de recursos

<pre><code>az group create --name groupName --location locationName</code></pre>

* ### Creación de IP Pública

<pre><code>az network public-ip create --resource-group resourceGroupName --name publicIPName
</code></pre>

* ### Creación de LoadBalancer con asociación de IP Pública

<pre><code>az network lb create --resource-group resourceGroupName --name loadBalancerName --frontend-ip-name frontendPoolName --backend-pool-name backendPoolName --public-ip-address publiIPName
</code></pre>

* ### Creación de Health Probe para el LoadBalancer

<pre><code>az network lb probe create --resource-group resourceGroupName --lb-name loadBalancerName --name healthProbeName --protocol tcp --port 80
</code></pre>

