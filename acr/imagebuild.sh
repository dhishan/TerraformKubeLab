ACR_NAME=containerRegistryLabDhishan
group=KubeLab
az acr build --registry $ACR_NAME -g $group --file node/data-api/Dockerfile --image smilr/data-api https://github.com/benc-uk/smilr.git

az acr build --registry $ACR_NAME -g $group --file node/frontend/Dockerfile --image smilr/frontend https://github.com/benc-uk/smilr.git

az acr repository list -g $group --name $ACR_NAME -o table