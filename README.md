# avtalabirchuk_platform
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
    
все pod в namespace kube-system восстановились после удаления, потому, что стратегия развертывания указана как Deployment т.е. строго поддерживать режим конфигурации в заданном виде. Если я не ошибаюсь


avtalabirchuk Platform repository
otus couses kubernetes

все pod в namespace kube-system восстановились после удаления, потому, что стратегия развертывания указана как Deployment т.е. строго поддерживать режим конфигурации в заданном виде. Если я не ошибаюсь