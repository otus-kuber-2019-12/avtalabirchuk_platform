установка helm 3
https://github.com/helm/helm#install
шпаргалка
 Создание release
  $ helm install <chart_name> --name=<release_name> --namespace=<namespace>
  $ kubectl get secrets -n <namespace> | grep <release_name>
  sh.helm.release.v1.<release_name>.v1 helm.sh/release.v1 1 115m
 Обновление release:
  $ helm upgrade <release_name> <chart_name> --namespace=<namespace>
  $ kubectl get secrets -n <namespace> | grep <release_name>
  sh.helm.release.v1.<release_name>.v1 helm.sh/release.v1 1 115m
  sh.helm.release.v1.<release_name>.v2 helm.sh/release.v1 1 56m
 Создание или обновление release:  
  $ helm upgrade --install <release_name> <chart_name> --namespace=<namespace>
  $ kubectl get secrets -n <namespace> | grep <release_name>
  sh.helm.release.v1.<release_name>.v1 helm.sh/release.v1 1 115m
  sh.helm.release.v1.<release_name>.v2 helm.sh/release.v1 1 56m
  sh.helm.release.v1.<release_name>.v3 helm.sh/release.v1 1 5s
Add helm repo
  По умолчанию в Helm 3 не установлен репозиторий stable
Посмотреть текущие репозитарии HELM 
  helm repo list
описание ключей https://helm.sh/docs/intro/
--wait -   ожидать успешного окончания установки 
--timeout - считать установку неуспешной по истечении указанного времени
--namespace - установить chart в определенный namespace (если не существует, необходимо создать)
--version - установить определенную версию chart
установка cert manager
    https://cert-manager.io/docs/
    https://cert-manager.io/docs/installation/kubernetes/
    - 1
        kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release0.9/deploy/manifests/00-crds.yaml
    - 2
        kubectl label namespace cert-manager certmanager.k8s.io/disable-validation="true"
    - 3
        helm upgrade --install cert-manager jetstack/cert-manager --wait \
        --namespace=cert-manager \
        --version=0.9.0
chartmuseum - 
helm 2 хранил информацию о релизах в configMap 
 - kubectl get configmaps -n kube-system
helm 3 хранит информацию о релизах в secrets

Провекрка yaml файлов с инструментом Kubeval

описание использования и последовательность действий
- для начала нам нужно завернуть в пакет наш chart 
 - helm package charts/test1
- получится chart tar архив, нам нужно его положить в chartmuseum пример curl --data-binary name.tgz https://chartmuseumv2.34.89.193.23.nip.io/api/charts
- чтобы воспользоваться нашим chart нам нужно добавить наш репозитарий
  - helm repo add name(dir) https://chartmuseumv2.34.89.193.23.nip.io
  - helm dependency update