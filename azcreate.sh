source ./setsecrets.sh

az aks create -n akslab -g KubeLab -l eastus -k 1.13.7 \
--service-principal $TF_VAR_SPN_ID \
--client-secret $TF_VAR_SPN_SECRET \
# --aad-client-app-id $TF_VAR_client_app_id \
# --aad-server-app-id $TF_VAR_server_app_id \
# --aad-server-app-secret $TF_VAR_server_app_secret \
# --aad-tenant-id $TF_VAR_tenant_id \
--node-count 3 \
--node-osdisk-size 30 \
--node-vm-size Standard_DS2_v2 \
--nodepool-name default \
--dns-name-prefix acctestagent1 \
--enable-vmss \
--enable-cluster-autoscaler \
--min-count 1 \
--max-count 3 \
--debug

