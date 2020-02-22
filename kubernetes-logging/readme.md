# lesson-9 kubernetes-loggin 

## подготовка кластера
 - 3 ноды для инфраструктурных сервиса и одна под приложение
 - отключаем stackdriver, чтобы небыло конфликта между Fluentd и стандартным Stackdriver
 - присваием нодам 3 [taint](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/)
   - kubectl taint node gke-lesson-9-loggin-infra-pool-c897e713-mr3h node-role=infra:NoSchedule
 - устанавливаем манифест
   - kubectl apply -f https://raw.githubusercontent.com/express42/otus-platform-snippets/master/Module-02/Logging/microservices-demo-without-resources.yaml -n microservices-demo
 - установим стек EFK (elastic fluentd bit, kibana)
   - [helm chart elastic и kibana](https://github.com/elastic/helm-charts)
    - добавляем 
     - helm repo add elastic https://helm.elastic.co
    - устанока (default)
     ```
     kubectl create ns observability
     # ElasticSearch
     helm upgrade --install elasticsearch elastic/elasticsearch --namespace observability
     # Kibana
     helm upgrade --install kibana elastic/kibana --namespace observability
     # Fluent Bit
     helm upgrade --install fluent-bit stable/fluent-bit --namespace observability
     ```
    - установка на служебных сервисов на определенную ноду
      - [helm chart elastic](https://github.com/elastic/helm-charts/tree/master/elasticsearch)
      - меняем tolerations 
        ```
        tolerations:
        - key: node-role
          operator: Equal
          value: infra
          effect: NoSchedule  
        ```
      -  меняем nodeSelector
        ```
        nodeSelector:
          cloud.google.com/gke-nodepool: infra-pool
        ```
    - обновляем chart
      - helm upgrade --install elasticsearch elastic/elasticsearch -n observability -f ./elasticsearch.values.yaml
    - устанавливаем nginx-ingress
      - helm upgrade --install nginx-ingress stable/nginx-ingress --wait \\n--namespace=observability \\n--version=1.17.1 \\n-f nginx-ingress.values.yaml
    - обновляем kibana
      - helm upgrade --install kibana elastic/kibana --namespace observability -f kibana.values.yaml
    - смотрим состояние всех подов
      - k get pods -n observability -o wide -w
    - получам доступ к кибане http://kibana.34.65.100.157.xip.io/app/kibana
    - обновляем fluentd чтобы получить логи
      - helm upgrade --install fluent-bit stable/fluent-bit --namespace observability -f fluentbit.values.yaml
    - из логов видно, что есть дублирующиеся поля
      - "Duplicate field 'time'\n at [Source: org.elasticsearch.common.bytes. ....
      - изменили фаил конфигурации
    - задание со звездочкой можно воспользоваться премером решением переименовать поле @timestamp ```Having to rename it is patchwork, so, think about providing better defaults instead.```
 - устанавливаем prometheus
   - helm upgrade --install prometheus stable/prometheus-operator --namespace observability
   - устанавливаем exporter elastic
     - helm upgrade --install elasticsearch-exporter stable/elasticsearch-exporter --set es.uri=http://elasticsearch-master:9200 --set serviceMonitor.enabled=true --namespace=observability
  - [PDB](https://kubernetes.io/docs/tasks/run-application/configure-pdb/)
   - PodDisruptionBudget
  - остановить ноды
   - k drain <node name> --ignore-daemonsets
  - восстановить ноды
   - kubectl uncordon <node name>
  - Для получения логов из nginx-ingress необходимо раскатать fluentd на все ноды
    - параметры раскатывания на все ноды нужно указать
     - tolerations: operator: "Exists"(если мы укажем equal то он установит fluentbit на определенные ноды)
  - allertmanager [Prometheus_alert_manager_elastic](https://github.com/justwatchcom/elasticsearch_exporter/blob/master/examples/prometheus/elasticsearch.rules)
   - [metrics_elasticsearch](https://habr.com/ru/company/yamoney/blog/358550/)
  - [KQL](https://www.elastic.co/guide/en/kibana/7.5/kuery-query.html) функции kibana
  - ingress logs format string [ingress_log](https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/configmap/#log-format-escape-json)
  