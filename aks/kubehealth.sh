group=KubeLab
name=akslab
az aks get-credentials -g $group -n $name

kubectl cluster-info
kubectl get nodes

kubectl get all -n kube-system

kubectl create clusterrolebinding kubernetes-dashboard \
--clusterrole=cluster-admin \
--serviceaccount=kube-system:kubernetes-dashboard

nohup az aks browse -g $group -n $name &