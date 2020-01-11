# kubernetes-networking установка minikube https://kubernetes.io/docs/tasks/tools/install-minikube/
- Readiness probe добавляется в области container
    -  kubectl describe позволяет посмотреть статус почему контейнер не ready Conditions
- команда 'ps aux | grep my_web_server_process' не имеет смысла потому, что она создает новый процесс PID XX и всегда возвращает 1 при любом создании, и смысла такого подхода нет т.к. будет создан новый процесс и всегда будет отдаваться(1) состояние как работает
- удалить не дожидаясь подтверждения ресурса kubectl delete pod/web --grace-period=0 --force
- describe детальная информация о подах, деплойментах и т.п.
- смотретб в кубере происходящие события kubectl get events --watch
- посмотреть и получить сервисы kubectl get services
- почитать про IP-Tables https://msazure.club/kubernetes-services-and-iptables/
- можно править конфиги сервера сразу kubectl --namespace kube-system
edit configmap/kube-proxy или в dashboard - включение minikube dashboard minikube dashboard
- описание настройки IPVS vs. IPTABLES https://github.com/kubernetes/kubernetes/blob/master/pkg/proxy/ipvs/README.md
    - отчистить iptables создаем файлик
        <!-- *nat
        -A POSTROUTING -s 172.17.0.0/16 ! -o docker0 -j MASQUERADE
        COMMIT
        *filter
        COMMIT
        *mangle
        COMMIT -->
    - применяем iptables-restore /tmp/iptables.cleanup Теперь надо подождать  примерно 30 секунд), пока kubeproxy восстановит правила для сервисов
- установить, что-нибудь в minikube заходим в fedora  командой toolbox
- установка MetalLB
  - kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.8.0/manifests/metallb.yaml ( в проде не делать а разобраться, что и за чем) l2 балансировщик(нужно поднять КонфигМап где прописывается ip диапазон и сервис где указывается тип LB LoadBalancer )
- посмотреть логи пода kubectl --namespace metallb-system logs pod/controller-XXXXXXXX-XXXXXX
- minikube ip ( узнать ip minikube)
- полезные фичи IPVS https://kubernetes.io/blog/2018/07/09/ipvs-based-in-cluster-load-balancing-deep-dive/
    - алгоритмы балансировки тут https://github.com/kubernetes/kubernetes/blob/1cb3b5807ec37490b4582f22d991c043cc468195/pkg/proxy/apis/config/types.go#L185
 - для того, чтобы открыть порты tcp/udp нужно создать 2 сервиса с общим ключом и разными именами (общий ключь https://github.com/danderson/metallb/issues/317)    - dns проверка осуществляется web-svc-cip.default.svc.cluster.local
      - где web-svc-cip имя сервиса
      - где default имя namespace
      - svc.cluster.local - общие имена
- ingress
  - установка kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/mandatory.yaml
# kubernetes-security lesson - 3(ссылка на оф. дкументацию по RBAC Authorization https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
- создание сервисного аккаунта и выделение ему прав админа
    - просмотр существующих ролей kubectl get clusterrole
    - просмотр существующих сервисных аккаунтов kubectl get serviceaccounts
    - смотрим какой тип авторизации задан команда kubectl cluster-info dump | grep authorization-mode
    - Используя плагин kubectl auth can-i запросить доступ kubectl auth can-i get deployments --as system:serviceaccount:default:bob 
    - помотреть сервисные аккаунты в namespace  kubectl get sa -n prometheus
    - Есть отдельные роли это RoleBindings и ClusterRoleBindings - распространяются на обычне роли и для кластера
    - Можно создавать обычные роли kind: Role, а можно для всего кластера kind: ClusterRole
        - если мы хотим указать все сервисные аккаунты то указываем system:serviceaccounts и выделяем отдельный namespace
    - можно управлять 3мя кластер ролями как для отдельного NameSpace так и для всего кластера. labels называются: 
        - rbac.authorization.k8s.io/aggregate-to-view: "true"  
        - rbac.authorization.k8s.io/aggregate-to-edit: "true"  
        - rbac.authorization.k8s.io/aggregate-to-admin: "true"  
        - в метадате указывается принадлежность к name space
# avtalabirchuk_platform
- github
    - https://github.com/otus-kuber-2019-12/avtalabirchuk_platform
- ДЗ Лекции
    - https://otus.ru/learning/42977/#/
- deployment strategy blue/green Canary
    - https://www.weave.works/blog/kubernetes-deployment-strategies
- zero downtime jenkins
    - https://kubernetes.io/blog/2018/04/30/zero-downtime-deployment-kubernetes-jenkins/
- max Unavailable max Surge
    - https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy
# otus
otus couses kubernetes

Основные команды lesson 2
Replicaset следит только за поддержанием в актуальном виде количество реплик, не обновляя имеджи и не диплоя их в кластер.
Получить состояние всех нод
    kubectl --kubeconfig ~/.kube/conf_kind get nodes
Увеличить кол-во реплик ad-hoc командой
    kubectl --kubeconfig ~/.kube/conf_kind scale replicaset frontend --replicas=3
проверка управления ReplicaSet 
    kubectl get rs frontend
Удалить и проверить состояние, что происходит с подами
    kubectl --kubeconfig ~/.kube/conf_kind delete pods -l app=frontend | kubectl --kubeconfig ~/.kube/conf_kind get pods -l app=frontend -w
проверить указанный образ в replicaSet 
     kubectl --kubeconfig ~/.kube/conf_kind  get replicaset frontend -o=jsonpath=='{.spec.template.spec.containers[0].image}'
Проверить образ из которого запущены pod
    kubectl --kubeconfig ~/.kube/conf_kind get pods -l app=frontend -o=jsonpath='{.items[0:3].spec.containers[0].image}'

Получить состояние Deployment
    kubectl --kubeconfig ~/.kube/conf_kind get deployment
После смены версии в образе и запуске deployment появляются 2 ReplicaSet одна со стым образом где запущеных пода 0из3 и новая где запущены поды 3из3

-o jsonpath    https://kubernetes.io/docs/reference/kubectl/jsonpath/

Проверить изменения нашего Deployment
    kubectl --kubeconfig ~/.kube/conf_kind rollout history deployment paymentservice
Deployment | Rollback
    откат к предыдущему deployment
        kubectl --kubeconfig ~/.kube/conf_kind rollout undo deployment paymentservice --to-revision=1 | kubectl --kubeconfig ~/.kube/conf_kind get rs -l app=paymentservice -w
Синтаксис gitlab-CI
deploy_job:
    stage: deploy
    script:
        - kubectl apply -f frontend-deployment.yaml
        - kubectl rollout status deployment/frontend --timeout=60s
rollback_deploy_job:
    stage: rollback
    script:
        - kubectl rollout undo deployment/frontend
    when: on_failure

В задании со * в спецификации с daemonset, чтобы повесить на ноды мастера нужно указывать tolerations в спецификации контейнеров

все pod в namespace kube-system восстановились после удаления, потому, что стратегия развертывания указана как Deployment т.е. строго поддерживать режим конфигурации в заданном виде. Если я не ошибаюсь


avtalabirchuk Platform repository
otus couses kubernetes

все pod в namespace kube-system восстановились после удаления, потому, что стратегия развертывания указана как Deployment т.е. строго поддерживать режим конфигурации в заданном виде. Если я не ошибаюсь