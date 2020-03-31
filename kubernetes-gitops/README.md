#lesson 17 Gitops и инструменты поставки
 - регистрируемся на gitlab.com
 - пушим туда свой проект microservice demo
 - собираем все docker images(задаем переменные)
   ```export TAG=v0.0.1 && export REPO_PREFIX=$user$svcname```
   - запускам из dir Hack скрипт, который сбилдит нам все images
     ```./make-docker-images.sh```
   - закидываем их в docker hub
     ```for i in $(docker images | grep atalabirchuk | awk '{print $1":"$2}'); do docker push $i ; done```
  - * задание со * - 1
   - автоматизаруйте создание Kubernetes кластера не сделано
   - установка istio как GKE аддона ( не реализовано)
  - * задание со * - 2 - реализовано есть фаил .gitlabci
   - подготовьте pipeline, который будет сождержать следующие стадии
    - Сборка docker образа для каждого микросервиса
    - Push данного образа в Docker Hub
      - настройка shell runner, выполнение скрипта создания(./make-docker-images.sh)
  - gitops подготовка
    - установка CRD, добавляющая в кластер новый ресурс
      - ```kubectl apply -f https://raw.githubusercontent.com/fluxcd/helm-operator/master/deploy/crds.yaml```
    - добавляем официальный репозиторий Flux
      - ```helm repo add fluxcd https://charts.fluxcd.io```
    - установка flux в кластер
      - ```kubectl create namespace flux```
      - ```helm upgrade --install flux fluxcd/flux -f flux.values.yaml --namespace flux```
    - установка Helm operator
      - ```helm upgrade --install helm-operator fluxcd/helm-operator -f helm-operator.values.yaml --namespace flux```
      - [документация Flux Helm Operator docs](https://docs.fluxcd.io)
     - установка fluxctl на локальную машину для управления CD инструментом
       - [установка_fluxctl](https://docs.fluxcd.io/en/stable/references/fluxctl.html)
     - добавляем публичный ключ flux в репозиторий gitlab
       - получить значение ключа ```fluxctl identity --k8s-fwd-ns flux``` https://gitlab.com/profile/keys
    - Проверка
      - создаем манифест в directory deploy/namespaces/microservice_demo.yaml
      - через время должен появиться описанный ns , проверить можно так
        - ```k  logs flux-667d64d9b7-zqn4b -n flux | grep caller```
          - ts=2020-03-15T11:07:23.761491883Z caller=sync.go:594 method=Sync cmd="kubectl apply -f -" took=542.103635ms err=null output="namespace/microservices-demo created"
    - HelmRelease(helm оператор)
      - добавляем frontend.yaml для теста
      - [описание HelmRelease значений](https://docs.fluxcd.io/en/latest/references/helm-operator-integration.html)
      - должен быть обязательно установлен prometheus operator
        - [prometheus_operator](https://coreos.com/operators/prometheus/docs/latest/user-guides/getting-started.html)
      - при добавлении файла обязательно должен появиться sync status
        - ```kubectl get helmrelease -n microservices-demo```
        - ```frontend   frontend   deployed   Helm release sync succeeded   11m``` 
      - дополнительно можно проверить статус
        - ```helm list -n microservices-demo```
      - flux инициализация синхронизации вручную
        - ```fluxctl --k8s-fwd-ns flux sync```
      - при изменении образа в dockerhub flux оператор сам обновляет релизы и вносит изменения в gitlab
        - собираем новый образ и пушим изменения в dockerhub
          - ```docker build -t atalabirchuk/frontend:v0.0.3 .```
          - ```docker push atalabirchuk/frontend:v0.0.3```
          - ```helm history frontend -n microservices-demo```
            - ```2               Sun Mar 15 13:23:01 2020        deployed        frontend-0.21.0 1.16.0          Upgrade complete```
        - внес изменение в deployment frontend переименовав имя в deployment на frontend-hipster.yaml - выложить значение в PR
         ```
         ts=2020-03-15T14:02:59.790768264Z caller=release.go:398 component=release release=frontend targetNamespace=microservices-demo resource=microservices-demo:helmrelease/frontend helmVersion=v3 info="chart has diverged" diff="  &helm.Chart{\n  \t... // 2 identical fields\n  \tAppVersion: \"1.16.0\",\n  \tValues:     helm.Values{\"environment\": string(\"develop\"), \"image\": map[string]interface{}{\"repository\": string(\"atalabirchuk/frontend\"), \"tag\": string(\"latest\")}, \"ingress\": map[string]interface{}{\"host\": string(\"35.234.150.195\")}},\n  \tTemplates: []*helm.File{\n  \t\t... // 2 identical elements\n  \t\t&{Name: \"templates/service.yaml\" 
         ... 
         ts=2020-03-15T14:02:59.804878108Z caller=helm.go:69 component=helm version=v3 info="preparing upgrade for frontend" targetNamespace=microservices-demo release=frontend ts=2020-03-15T14:03:00.261914434Z caller=helm.go:69 component=helm version=v3 info="performing update for frontend" targetNamespace=microservices-demo release=frontend ts=2020-03-15T14:03:00.313994488Z caller=helm.go:69 component=helm version=v3 info="creating upgraded release for frontend" targetNamespace=microservices-demo release=frontend ts=2020-03-15T14:03:00.330073797Z caller=helm.go:69 component=helm version=v3 info="checking 5 resources for changes" targetNamespace=microservices-demo release=frontend ts=2020-03-15T14:03:00.338314942Z caller=helm.go:69 component=helm version=v3 info="Looks like there are no changes for Service \"frontend\"" targetNamespace=microservices-demo relase=frontend ts=2020-03-15T14:03:00.352627386Z caller=helm.go:69 component=helm version=v3 info="Created a new Deployment called \"frontend-hipster\" in microservices-demo\n" targetNamespace=microservices-demo release=frontend ts=2020-03-15T14:03:00.365073284Z caller=helm.go:69 component=helm version=v3 info="Looks like there are no changes for Gateway \"frontend\"" targetNamespace=microservices-demo release=frontend ts=2020-03-15T14:03:00.395905951Z caller=helm.go:69 component=helm version=v3 info="Looks like there are no changes for ServiceMonitor \"frontend\"" targetNamespace=microservices-demo release=frontend ts=2020-03-15T14:03:00.437612304Z caller=helm.go:69 component=helm version=v3 info="Looks like there are no changes for VirtualService \"frontend\"" targetNamespace=microservices-demo release=frontend ts=2020-03-15T14:03:00.471962475Z caller=helm.go:69 component=helm version=v3 info="updating status for upgraded release for frontend" targetNamespace=microservices-demo release=frontend
         ```
      - применяем все gitops манифесты
       - проверяем статус ```helm list -n microservices-demo | nl``` 11 сервисов
    - Полездные команды fluxctl
      - export FLUX_FORWARD_NAMESPACE=flux переменная окружения, указывающая на namespace, в который установлен flux (альтернатива ключу --k8s-fwd-ns <flux installation ns>)
      - fluxctl list-workloads -a  --k8s-fwd-ns(имя немспейса) flux посмотреть все workloads, которые находятся в зоне видимости flux
      - fluxctl list-images --k8s-fwd-ns flux - посмотреть все Docker образы, используемые в кластере (в namespace microservices-demo)
      - fluxctl automate/deautomate - включить/выключить автоматизацию управления workload
      - fluxctl policy -w microservices-demo:helmrelease/frontend --tag-all='semver:~0.1' - установить всем сервисам в workload microservices- demo:helmrelease/frontend политику обновления образов из Registry на базе семантического версионирования c маской 0.1.*
      - fluxctl sync - приндительно запустить синхронизацию состояния git-репозитория с кластером
      - fluxctl release --workload=microservices-demo:helmrelease/frontend  --update-all-images - принудительно инициировать сканирование Registry на предмет наличия свежих Docker образов
    ## Canary deployments с Flagger и Istio
      - Flagger - оператор Кубернетес созданные для авторматизации canary deployments
      - установка istio с помощью istioctl 
        - [Документация по установке](https://istio.io/docs/setup/install/istioctl/)
        - [Шаги установки](https://istio.io/docs/setup/getting-started/)
        - [configuration profile](https://istio.io/docs/setup/additional-setup/config-profiles/)
  ## задание со * установка isio operator
      - Установка Flagger
        - Добавление helm-репозитория flagger:
          - `helm repo add flagger https://flagger.app`
        - Установка CRD для Flagger:
          - `kubectl apply -f https://raw.githubusercontent.com/weaveworks/flagger/master/artifacts/flagger/crd.yaml`
        - Установка flagger с указанием использовать Istio:
          helm upgrade --install flagger flagger/flagger \
          --namespace=istio-system \
          --set crd.create=false \
          --set meshProvider=istio \
          --set metricsServer=http://prometheus:9090
        - проверка синхронизации нашего gitops
          - `kubectl get ns microservices-demo --show-labels`
        - простой спосб добавить sidecar контейнер в уже запущенный pod - удалить их
          - `kubectl delete pods --all -n microservices-demo`
        - должен появиться у каждого пода istio-proxy
          - `kubectl describe pod -l app=frontend -n microservices-demo`
        - созданный gateway можно увидеть след. образом
          - kubectl get gateway -n microservices-demo
        - получить external GW
          - kubectl get svc istio-ingressgateway -n istio-system
      - flagger canary
        - [Canary Custom Resource](https://docs.flagger.app/how-it-works#canary-custom-resource)
        - применяем canary.yaml - microservices-demo/deploy/charts/frontend/templates/canary.yaml
        - проверяем успешную инициализацию `kubectl get canary -n microservices-demo`
        - проверка пода, что он обновил название `kubectl get pods -n microservices-demo -l app=frontend-primary`
        - test
          - kubectl describe canary frontend -n microservices-demo


     


    


 