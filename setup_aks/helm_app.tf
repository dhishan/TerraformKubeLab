



# data "helm_repository" "stable" {
#     name = "stable"
#     url  = "https://kubernetes-charts.storage.googleapis.com"
# }

# helm install stable/mongodb --name orders-mongo --set mongodbUsername=orders-user,mongodbPassword=orders-password,mongodbDatabase=akschallenge
# resource "helm_release" "mongodb" {
#   name       = "orders-mongo"
#   repository = "${data.helm_repository.stable.metadata.0.name}"
#   chart      = "stable/mongodb"

#   # values = [
#   #   "${file("values.yaml")}"
#   # ]
#   set {
#     name  = "mongodbUsername"
#     value = "orders-user"
#   }

#   set {
#     name  = "mongodbPassword"
#     value = "orders-password"
#   }

#   set_string {
#     name  = "mongodbDatabase"
#     value = "akschallenge"
#   }
# }

# kubectl create secret generic mongodb --from-literal=mongoHost="orders-mongo-mongodb.default.svc.cluster.local" --from-literal=mongoUser="orders-user" --from-literal=mongoPassword="orders-password"
# resource "kubernetes_secret" "generic" {
#   metadata {
#     name = "mongodb"
#   }

#   data = {
#     mongoHost = "orders-mongo-mongodb.default.svc.cluster.local"
#     mongoUser = "orders-user"
#     mongoPassword = "orders-password"
#   }

#   # type = "kubernetes.io/basic-auth"
# }
