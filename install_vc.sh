helm init
helm init --upgrade --service-account tiller

pushd HashicorpVault/consul-helm
helm install . --name c1
popd

kubectl wait --for=condition=Ready pod/c1-consul-server-0

pushd HashicorpVault/vault-helm
helm install . --name v1 --values extras.yaml
popd