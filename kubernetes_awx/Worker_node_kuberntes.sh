sudo apt-get install -y wget gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
mkdir /etc/docker
cat <<EOF | sudo tee /etc/docker/daemon.json
{
"exec-opts": ["native.cgroupdriver=systemd"],
"log-driver": "json-file",
"log-opts": {
"max-size": "100m"
},
"storage-driver": "overlay2"
}
systemctl enable --now docker
systemctl daemon-reload
systemctl restart docker
usermod -aG docker ${USER}
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
apt-get update -y
apt-get install -y apt-transport-https ca-certificates curl
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl
#nano /etc/hosts
sudo rm /etc/containerd/config.toml
sudo systemctl restart containerd
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
#nano /etc/hosts
#kubeadm join 192.168.19.141:6443 --token flojgd.mokvtcoiysh1wuoc         --discovery-token-ca-cert-hash sha256:9dbcf7147a7fec829673cbebb7f579c09efaf66068bad7943541972af2c9f56c
#fdisk -l
#fdisk /dev/sdb
#mkfs -t ext3 /dev/sdb1
#mkdir /mnt/data
#echo "/dev/sdb1 /mnt/data ext3 defaults 0 0" >> /etc/fstab
#mount -a
#df -h
#wget https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.19/deploy/local-path-storage.yaml -O /root/local-path-storage.yaml
#sed -i "s#/opt/local-path-provisioner#/mnt/data#g" /root/local-path-storage.yaml
kubectl apply -f /root/local-path-storage.yaml
kubectl patch sc local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
kubectl logs -f deployments/awx-operator-controller-manager -c awx-manager
kubectl config set-context --current --namespace=awx
kubectl get secret awx-demo-admin-password -o jsonpath="{.data.password}" | base64 --decode
