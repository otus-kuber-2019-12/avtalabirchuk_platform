## Создание нод для кластера
- master - 1 экземпляр (n1-standard-2)
- worker - 3 экземпляра (n1-standard-1)
### отключаем swap
 - `swapoff -a`
### включаем маршрутизацию
 ```
 cat > /etc/sysctl.d/99-kubernetes-cri.conf <<EOF
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward= 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sysctl --system
```
### устновка docker
 `curl https://get.docker.com | sh`
 ```
 cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

mkdir -p /etc/systemd/system/docker.service.d
# Restart docker.
systemctl daemon-reload && \
systemctl restart docker

 ```
### Установка kubeadm, kubelet and kubectl
```
# установка версии 1.17
apt-get update && apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF > /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y kubelet=1.17.4-00 kubeadm=1.17.4-00 kubectl=1.17.4-00
```
### установка мастер ноды
`kubeadm init --pod-network-cidr=192.168.0.0/24`
 - важно вот директивы которые используются при установке куба
 ```
 [kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
 [kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
 [certs] Using certificateDir folder "/etc/kubernetes/pki"
 [certs] apiserver serving cert is signed for DNS names [master kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 10.156.0.16]
 [kubeconfig] Using kubeconfig folder "/etc/kubernetes"
 [kubeconfig] Writing "admin.conf" kubeconfig file
 [kubeconfig] Writing "kubelet.conf" kubeconfig file
 [kubeconfig] Writing "controller-manager.conf" kubeconfig file
 [kubeconfig] Writing "scheduler.conf" kubeconfig file
 [control-plane] Using manifest folder "/etc/kubernetes/manifests"
 [control-plane] Using manifest folder "/etc/kubernetes/manifests"
 [control-plane] Creating static Pod manifest for "kube-apiserver"
 [control-plane] Creating static Pod manifest for "kube-controller-manager"
 W0410 13:05:29.512751    8022 manifests.go:214] the default kube-apiserver authorization-mode is "Node,RBAC"; using "Node,RBAC"
 [control-plane] Creating static Pod manifest for "kube-scheduler"
 W0410 13:05:29.515795    8022 manifests.go:214] the default kube-apiserver authorization-mode is "Node,RBAC"; using "Node,RBAC"
 [etcd] Creating static Pod manifest for local etcd in "/etc/kubernetes/manifests"
 [wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/manifests". This can take up to 4m0s
 [bootstrap-token] Using token: h0c9e7.qeb7ffwkelwg22qw
 [kubelet-finalize] Updating "/etc/kubernetes/kubelet.conf" to point to a rotatable kubelet client certificate and key
 # хранение конфигов
 To start using your cluster, you need to run the following as a regular user:
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
 #команда для деплоя сетевого плагина
 You should now deploy a pod network to the cluster.
 Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/
  # команда для подключения воркерноды
  kubeadm join 10.156.0.16:6443 --token h0c9e7.qeb7ffwkelwg22qw \
    --discovery-token-ca-cert-hash sha256:15ead3e4d2a89312f9580b04f59115981f6f711de4a4c80cff2abadb5d136a16
 ```
### [устанавливаем сетевой плагин](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#pod-network)
 - устанавливливаем calico
   `kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml`
### подключаем воркер ноды
 - устанавливаем kubeadm, kubelet, kubectl на каждую ноду
  `apt-get install -y kubelet=1.17.4-00 kubeadm=1.17.4-00 kubectl=1.17.4-00`
 - выполняем join `kubeadm join`
   ```
   kubeadm join 10.156.0.16:6443 --token h0c9e7.qeb7ffwkelwg22qw \
    --discovery-token-ca-cert-hash sha256:15ead3e4d2a89312f9580b04f59115981f6f711de4a4c80cff2abadb5d136a16
   ```
   посмотреть текущие токены для подключения воркер нод
   `kubeadm token list`
   
   получить Хеш
   ```
   openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | \
   openssl dgst -sha256 -hex | sed 's/^.* //'
   ```

### обновление кластера с помощью kubeadm
  - обновлять ноды по очереди начиная с мастера!!!
  Допускается, отставание версий worker-нод от master, но не
    наоборот. Поэтому обновление будем начинать с нее master-нода у
    нас версии 1.17.4
 - обновляем пакеты 
 ```
  apt-get update && apt-get install -y kubeadm=1.18.0-00 \
  kubelet=1.18.0-00 kubectl=1.18.0-00
 ```
 - посмотреть версии
   - kubelet --version
   - kubectl api-versions
#### обновление компонентов
 - API-server
 - kube-proxy
 - controller-manager
 - посмотреть план обновления `kubeadm upgrade plan`
 - посмотреть конфигурацию сервера `kubectl -n kube-system get cm kubeadm-config -oyaml`
 - применение изменений `kubeadm upgrade apply v1.18.0`
   - важно
     -  Will prepull images for components [kube-apiserver kube-controller-manager kube-scheduler etcd]
    ```
     [upgrade/staticpods] Preparing for "kube-apiserver" upgrade
     [upgrade/staticpods] Renewing apiserver certificate
     [upgrade/staticpods] Renewing apiserver-kubelet-client certificate
     [upgrade/staticpods] Renewing front-proxy-client certificate
     [upgrade/staticpods] Renewing apiserver-etcd-client certificate
     [upgrade/staticpods] Moved new manifest to "/etc/kubernetes/manifests/kube-apiserver.yaml" and backed up old manifest to "/etc/kubernetes/tmp/kubeadm-backup-manifests-2020-04-11-07-23-40/kube-apiserver.yaml"
     [upgrade/staticpods] Renewing controller-manager.conf certificate
     [upgrade/staticpods] Moved new manifest to "/etc/kubernetes/manifests/kube-controller-manager.yaml" and backed up old manifest to "/etc/kubernetes/tmp/kubeadm-backup-manifests-2020-04-11-07-23-40/kube-controller-manager.yaml"
     [upgrade/staticpods] Moved new manifest to "/etc/kubernetes/manifests/kube-scheduler.yaml" and backed up old manifest to "/etc/kubernetes/tmp/kubeadm-backup-manifests-2020-04-11-07-23-40/kube-scheduler.yaml"
     [kubelet-start] Downloading configuration for the kubelet from the "kubelet-config-1.18" ConfigMap in the kube-system namespace
     [kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
     [upgrade/successful] SUCCESS! Your cluster was upgraded to "v1.18.0". Enjoy!
    ```
 - проверка версий
  ```
  kubeadm version
  kubelet --version
  kubectl version
  kubectl describe pod <Ваш под с API сервером> -n kube-system
  ```
 - Вывод worker-нод из планирования
    - начинаем с первой ноды
    `kubectl drain worker2` note `kubectl drain убирает всю нагрузку, кроме DaemonSet,поэтому мы явно должны сказать, что уведомлены об этом`
    `kubectl drain worker1 --ignore-daemonsets`
    - проверяем статус должен поменятся на ноде в которой мы выполнили drain `kubectl get nodes -o wide`
      ` worker1   Ready,SchedulingDisabled `
    - на вывееной ноде из боя выполняем команду установки
    `   apt-get update && apt-get install -y kubeadm=1.18.0-00 kubelet=1.18.0-00 && systemctl restart kubelet `
    - проверка `kubectl get nodes -o wide`
     `worker1   Ready,SchedulingDisabled   <none>   17h   v1.18.0`
    - Если все ок, то возвращаем обратно ноду в строй
     ` kubectl uncordon worker1`
## [kubespray](https://github.com/kubernetes-sigs/kubespray)

### Задание со * подключить к уже имеющемся кластеру [еще одну мастер ноду](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/)
 - нужно создать балансировщик нагрузки который будет стоять перед мастер нодами
  - создаем отдельную машину ubuntu-18.04 LTS
  - устанавливаем на нее haproxy
    ` apt-get update && apt-get upgrade && apt-get install -y haproxy `
    ` mv /etc/haproxy/haproxy.cfg{,.back}`
    создаем конфиг ` vim /etc/haproxy/haproxy.cfg`
      ```
global
    user haproxy
    group haproxy
defaults
    mode http
    log global
    retries 2
    timeout connect 3000ms
    timeout server 5000ms
    timeout client 5000ms
frontend kubernetes
    bind 10.156.0.21:6443
    option tcplog
    mode tcp
    default_backend kubernetes-master-nodes
backend kubernetes-master-nodes    
    mode tcp
    balance roundrobin
    option tcp-check     
    server k8s-master-0 10.156.0.22:6443 check fall 3 rise 2
    server k8s-master-1 10.156.0.23:6443 check fall 3 rise 2
    server k8s-master-3 10.156.0.24:6443 check fall 3 rise 2
      ```
 - по хорошему для HA нужно еще использовать технолгию VRRP (организуется демонами keepalived, Heartbeat, watchdog)
 - создаем ssh ключ на мастер ноде 1 
  - отключаем swapp `swapoff -a`
  - включаем маршрутизацию
  ```
cat > /etc/sysctl.d/99-kubernetes-cri.conf <<EOF
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward= 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sysctl --system
    ```
  - устанавливаем docker `curl https://get.docker.com | sh`
  - установим нужные нам зависимости пакетов, такой же версии как текущий мастер
    ```
apt-get update && apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF > /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update && apt-get install -y kubeadm=1.18.0-00 \
kubelet=1.18.0-00 kubectl=1.18.0-00
    ```
  - `ssh-keygen`
  - копируем публичный ключ на новую мастер ноду
  - инициализируем первый мастер командой
  `kubeadm init --pod-network-cidr=192.168.0.0/24 --control-plane-endpoint "10.156.0.21:6443" --upload-certs`
  - [можно руками скопировать файлы, сертификаты с мастер ноды на новый мастер](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/#manual-certs)
  - копируем конфиг для управления
  ```
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config  
  ```
  - устанавливаем CNI calico
  `kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml`
  - присоединяем новый мастер к мастеру используя ключ --control-plane (ВАЖНО если используется флаг --upload-certs, то они живут 2 часа, потом протухают Note: The kubeadm-certs Secret and decryption key expire after two hours. Их можно обновить `sudo kubeadm init phase upload-certs --upload-certs` To re-upload the certificates and generate a new decryption key, use the following command on a control plane node that is already joined to the cluster: )
   ```
  kubeadm join 10.156.0.21:6443 --token 66yegt.c4f0gcrr64yye8rm \
    --discovery-token-ca-cert-hash sha256:a2e0c4afd014f4080d45ddd1581af581ae142fada9d49502eb7e68637bade45a \
    --control-plane --certificate-key 3e110562428dc6e58413040861aa3000310f2495d3c040480dbff6fa4321ebbd

   ```
 - добавляем воркер node (отключаем swap устанавливаем докер и нужные пакеты, как указано выше)
  ```
kubeadm join 10.156.0.21:6443 --token 66yegt.c4f0gcrr64yye8rm \
    --discovery-token-ca-cert-hash sha256:a2e0c4afd014f4080d45ddd1581af581ae142fada9d49502eb7e68637bade45a
  ``
 - вывод команды `kubeclt get nodes`
    root@master-1:~# kubectl get nodes
    NAME       STATUS   ROLES    AGE   VERSION
    master-1   Ready    master   29m   v1.18.0
    master-2   Ready    master   15m   v1.18.0
    master-3   Ready    master   13m   v1.18.0
    worker-1   Ready    <none>   49s   v1.18.0
    worker-2   Ready    <none>   34s   v1.18.0
 - вывод команды `kubectl get pods -A`
        NAMESPACE     NAME                                       READY   STATUS    RESTARTS   AGE
        default       nginx-deployment-7c5b79bdcf-5s5mc          1/1     Running   0          39s
        default       nginx-deployment-7c5b79bdcf-8r82k          1/1     Running   0          39s
        default       nginx-deployment-7c5b79bdcf-qtvf2          1/1     Running   0          39s
        default       nginx-deployment-7c5b79bdcf-vhgq8          1/1     Running   0          39s
        kube-system   calico-kube-controllers-555fc8cc5c-zk942   1/1     Running   0          22m
        kube-system   calico-node-fh9wh                          1/1     Running   0          4m29s
        kube-system   calico-node-pdl8n                          1/1     Running   0          22m
        kube-system   calico-node-rcmt2                          1/1     Running   0          17m
        kube-system   calico-node-x58bz                          1/1     Running   0          19m
        kube-system   calico-node-zzzsr                          1/1     Running   0          4m44s
        kube-system   coredns-66bff467f8-2g5kg                   1/1     Running   0          32m
        kube-system   coredns-66bff467f8-h69zm                   1/1     Running   0          32m
        kube-system   etcd-master-1                              1/1     Running   0          33m
        kube-system   etcd-master-2                              1/1     Running   0          19m
        kube-system   etcd-master-3                              1/1     Running   0          17m
        kube-system   kube-apiserver-master-1                    1/1     Running   0          33m
        kube-system   kube-apiserver-master-2                    1/1     Running   0          19m
        kube-system   kube-apiserver-master-3                    1/1     Running   0          17m
        kube-system   kube-controller-manager-master-1           1/1     Running   1          33m
        kube-system   kube-controller-manager-master-2           1/1     Running   0          19m
        kube-system   kube-controller-manager-master-3           1/1     Running   0          17m
        kube-system   kube-proxy-5bwvn                           1/1     Running   0          4m44s
        kube-system   kube-proxy-kqttt                           1/1     Running   0          32m
        kube-system   kube-proxy-pb5gq                           1/1     Running   0          19m
        kube-system   kube-proxy-s9t78                           1/1     Running   0          17m
        kube-system   kube-proxy-svksp                           1/1     Running   0          4m29s
        kube-system   kube-scheduler-master-1                    1/1     Running   1          33m
        kube-system   kube-scheduler-master-2                    1/1     Running   0          19m
        kube-system   kube-scheduler-master-3                    1/1     Running   0          17m