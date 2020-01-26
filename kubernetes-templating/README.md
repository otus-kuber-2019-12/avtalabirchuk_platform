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

### установка harbor CHART VERSION 1.1.2
- kubectl create ns harbor1
- helm upgrade --install harbor harbor/harbor --wait \
--namespace=harbor1 \
--version=1.1.2 \
-f /home/andrew/kubernetis/github-otus/avtalabirchuk_platform/kubernetes-templating/harbor/values.yaml
- default logs\pass admin/Harbor12345
- получить информацию о release
 - kubectl get secrets -n harbor -l owner=helm
### использование helmfile https://github.com/roboll/helmfile
- установка brew install helmfile
- использование и примеры
  - пример let'encrypt https://github.com/cloudposse/helmfiles/blob/master/releases/cert-manager.yaml
  - https://gist.github.com/zloeber/e280030aa819be22653809bb1d353c0d
  - запуск helmfile --log-level=debug --environment production apply (можно без дебага)
### написание своего helmchart
- разделение frontend hipstershop
  - создание заготовка helm 
   - helm create kubernetes-templating/frontend
- обязательно указываем значения по умолчанию пример
  - targetPort: {{ .Values.service.ports.targetPort | default "8080" }}
  - условия, если мы хотим использовать условия, то нужно указывать его в нужном столбце yaml -     - пример(структура https://helm.sh/docs/chart_template_guide/control_structures/)
     -    {{- if eq .Values.service.type.type "NodePort" }}    
     -    nodePort: {{ .Values.service.ports.nodePort | default "30675" }}
     -    {{- end }}
 - переменные можно создавать и присваивать их
  - пример переменных
    -{{- if .Values.ingress.enabled -}}
    -{{- $fullName := include "kubernetes-templating.fullname" . -}}
    -{{- $svcPort := .Values.service.port -}}
- удаление своего helm chart  "helm delete frontend -n hipster-shop"
- dependencies (зависимости helm) https://helm.sh/docs/topics/chart_best_practices/dependencies/
  - указываются в файле Chart.yaml содержание такого рода
    dependencies:
    - name: frontend
        version: 0.1.0
        repository: "file://../frontend" - репозиторий где находится эта зависимость
   - обновить зависимость 'helm dependency update hipster-shop'
   - создается фаил charts/frontend-0.1.0.tgz из указанного репозитория file://../frontend
   - обновляем проект helm upgrade --install hipster-shop hipster-shop --namespace hipster-shop
- переопределение переменной из values.yaml задается командой --set 
  --set frontend.service.ports.nodePort=31234
   - helm upgrade --install hipster-shop hipster-shop --namespace hipster-shop --set frontend.service.ports.nodePort=31234 
     - это в том случае если мы обращаемся к зависимости frontend(или другой)
     - Если мы хотим использовать не зависимость то указываем абсолютный путь до переменной которую мы хотим переопределить service.ports.nodePort=31234
Задание со * создаем свой chart
 - список всех chart stable
  - https://github.com/helm/charts/tree/master/stable
  - пример с sentry dependencies redis https://github.com/helm/charts/blob/master/stable/sentry/values.yaml

Секреты в helm:
 - в linux подключить репозиторй brew, установить зависимости:
   - brew install sops
   - brew install gnupg2
   - brew install gnu-getopt
   - helm plugin install https://github.com/futuresimple/helm-secrets --version 2.0.2
- выполнить команды:
 - генерация ключа PGP
 - gpg --full-generate-key (отвечаем на все вопросы)
 - посмотреть полученный ключ 
   - gpg -k вывод
   /home/andrew/.gnupg/pubring.kbx
    -------------------------------
    pub   rsa3072 2020-01-26 [SC] [годен до: 2021-01-25]
        B6C1FADA020AABD195B3546AAAA099B70A8872E5
    uid         [  абсолютно ] atalabirchuk <talabirchuk.av@gmail.com>
    sub   rsa3072 2020-01-26 [E] [годен до: 2021-01-25]
    - шифрование файла 
     - sops -e -i --pgp <$ID> secrets.yaml ( где ID вывод изп предыдущей команды B6C1FADA020AABD195B3546AAAA099B70A8872E5)
- расшифровка файла
 - любая из команд
    # helm secrets
    helm secrets view secrets.yaml
    # sops
    sops -d secrets.yaml
- deploy secrets в проект 
    helm secrets upgrade --install frontend kubernetes-templating/frontend --namespace
    hipster-shop \
    -f kubernetes-templating/frontend/values.yaml \
    -f kubernetes-templating/frontend/secrets.yam
- kubecfg установка    
  - brew install kubecfg
  - проверка версии kubecfg version
  - пример файла конфигурации можно посмотреть в репозитории https://github.com/bitnami/kubecfg/blob/master/examples/guestbook.jsonnet
  - в целом все конфигурируется через фаил services.jsonnet
    - нужно добавить библиотеку перез конфигурированием (используем готовую от битнами https://github.com/bitnami-labs/kube-libsonnet/)
      - local kube = import "https://raw.githubusercontent.com/bitnami-labs/kube-libsonnet/master/kube.libsonnet";
    - логика использования
      - 1 Пишем общий для сервисов https://raw.githubusercontent.com/express42/otus-platform-snippets/master/Module-04/05-Templating/hipster-shop-jsonnet/common.jsonnet , включающий описание service и deployment
      - 2. наследуеся(https://raw.githubusercontent.com/express42/otus-platform-snippets/master/Module-04/05-Templating/hipster-shop-jsonnet/payment-shipping.jsonnet) от него, указывая параметры для конкретных сервисов
    - запустить генерацию манифестов можно командой 
      - kubecfg show services.jsonnet
    - выполняем полученные манифесты kubecfg update services.jsonnet --namespace hipster-shop

- Задание со * jsonnet Выберите еще один микросервис из состава hipster-shop (https://otus.ru/media-private/b7/f3/%D0%94%D0%97_%D0%A8%D0%B0%D0%B1%D0%BB%D0%BE%D0%BD%D0%B8%D0%B7%D0%B0%D1%86%D0%B8%D1%8F_%D0%BC%D0%B0%D0%BD%D0%B8%D1%84%D0%B5%D1%81%D1%82%D0%BE%D0%B2-26527-b7f384.pdf?hash=84zS3twNLIRZygG769NntA&expires=1579976827) страница 67
 - https://github.com/deepmind/kapitan
 - https://github.com/splunk/qbec

- Kustomize

