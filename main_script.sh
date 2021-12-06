#!/bin/bash
#Deploy vagrant vm
vagrant up
#transfer ssh keys
./sshkeys.sh
#run ansible-playbook
cd kubespray
ansible-playbook -i inventory/mycluster/hosts.yaml -u vagrant cluster.yml -b
cd ..
#configure workers /mnt rights
ssh vagrant@10.100.101.102 "sudo chmod 777 /mnt"
# configuring kubectl for manage cluster from master node
ssh vagrant@10.100.101.100 "sudo chmod 644 /etc/kubernetes/admin.conf && export KUBECONFIG=/etc/kubernetes/admin.conf"
# configuring local machine to manage k8s cluster
scp vagrant@10.100.101.100:/etc/kubernetes/admin.conf ~/.kube/mycluster.conf && export KUBECONFIG=~/.kube/mycluster.conf
# Creating ns: jenkins, kafka, monitoring
kubectl apply -f Namespaces
sleep 10
# create secret etcd-certs
ssh vagrant@10.100.101.100 "sudo chmod 644 /etc/ssl/etcd/ssl && sudo kubectl create secret generic etcd-certs --from-file=/etc/ssl/etcd/ssl -n monitoring"
#Creating pv for kafka and jenkins
kubectl apply -f Volumes
#Creating ingress
kubectl apply -f ingress-cm.yaml
#Create secrets and cm
kubectl apply -f Secrets_configmaps
#Deploy jenkins
kubectl apply -f deploy_jenkins
#install node exporter to etcd node
scp nodeexporter.sh node_exporter.service vagrant@10.100.101.101:~
ssh vagrant@10.100.101.101 "./nodeexporter.sh"
#deploy prometheus
scp prometheus-values.yaml vagrant@10.100.101.100:~
kubectl -n monitoring create cm grafana-general-dash --from-file=GeneralDash.json
kubectl -n monitoring label cm grafana-general-dash grafana_dashboard=general-dash
ssh vagrant@10.100.101.100 "helm repo add prometheus-community https://prometheus-community.github.io/helm-charts && helm repo update && export KUBECONFIG=/etc/kubernetes/admin.conf && helm install -f prometheus-values.yaml monitoring -n monitoring prometheus-community/kube-prometheus-stack"
sleep 20
#deploy kafka
scp kafka-values.yaml vagrant@10.100.101.100:~
ssh vagrant@10.100.101.100 "helm repo add bitnami https://charts.bitnami.com/bitnami && helm repo update && export KUBECONFIG=/etc/kubernetes/admin.conf && helm install -f kafka-values.yaml kafka -n kafka bitnami/kafka"

