# taint yout master node
kubectl taint node <master-node-name> node.cloudprovider.kubernetes.io/uninitialized=true:NoSchedule

# apply the release manifest for vsphere cpi
kubectl apply -f vsphere-cloud-controller-manager.yaml

# remove conf file for security reasin, if you wanna to
rm vsphere-cloud-controller-manager.yaml

# edit core dns forwarder config
kubectl -n kube-system edit configmap coredns

: '
   vsanfs-sh.prv:53 {         # vsanfs-sh.prv is the DNS suffix for vSAN file service
   errors
   cache 30
   forward . 192.168.1.1      # your dns ip
   }
 '

# create namespace
kubectl apply -f namespace.yaml

# create a Kubernetes secret for vSphere credentials
kubectl create secret generic vsphere-config-secret --from-file=csi-vsphere.conf --namespace=vmware-system-csi

# Delete the configuration file for security purposes, if you wanna to
rm csi-vsphere.conf

# Deploy vSphere Container Storage Plug-in
kubectl -f vsphere-csi-driver.yaml

# verify deployment
kubectl get deployment --namespace=vmware-system-csi
kubectl get daemonsets vsphere-csi-node --namespace=vmware-system-csi
kubectl describe csidrivers
kubectl get CSINode
