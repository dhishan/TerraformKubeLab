source ./setsecrets.sh

export TF_VAR_rgName=KubeLab
export TF_VAR_aksName=akslab

destroy_all()
{
    echo "Destroying Everything"
    
    pushd acr
    terraform init
    terraform destroy
    popd

    pushd aks
    terraform init
    terraform destroy
    popd
}

if [ "$2" = "destroy" ] && [ "$1" = "all" ]
then
    destroy_all
    exit 0
fi

pushd $1
terraform init
terraform $2

if [ "$1" = "aks" ] && [ "$2" = "apply" ]
then
    source kubehealth.sh
fi

if [ "$1" = "acr" ] && [ "$2" = "apply" ]
then
    source imagebuild.sh
fi

popd


