Установка prometheus оператор:
 - repo https://github.com/helm/charts/tree/master/stable/prometheus-operator
 - helm repo update
 - применение values.yaml
   - helm install stable/prometheus-operator --wait -f ./values.yaml
- запуск проекта
  - установка оператора prometheus идем пить кофе, в миникб так и не поставилось, а вот в GKE потребовалось минут 10-15
  - применяем deployment
  - применяем service
  - применяем service-monitor
  - открываем графану ч.з. nginx kubectl apply -f ingress-grafana.yaml
  - заходим на ресурс https://grafana.34.89.193.23.nip.io/
  - импортируем стандартный дашборд nginx находится в папке проекта
  - смотрим за стандартными метриками nginx
Метрики и мониторинг
HPA - horizontal pod Autoscaler

USE metod
 - resource
 - utilization
 - satuation
 - errors
Red metod

prometheus - федерация (жирный прометеус)
 кросс сервисная федерация
 хранение метрик отдельные хранилища
  - victoria Metrics
  - Cortrex
  - Thanos (схема таноса стр. 44)
   - prometheus Thanos - sidecar (контейнер) собирает и предает дальше метрики
  - clickhouse ^_^
- deadmen switch - если не поступают метрики от промитеуса, прийдет уведомление, что прометеус не работает
- перезапустить прометея с измененным конфигом 
  - http://127.0.0.1:9090/-/reload


у minio есть distributed mode - вроде это как раз к HA относится. 
- https://docs.min.io/docs/distributed-minio-quickstart-guide.html 
- установка через хельм слайд 52 из 79 время 1:15
загрузка дашбордов в графану 1:30  59 страница

nodepinger дашборд в графане

HelmChart Prometheus
https://github.com/helm/charts/tree/master/stable/prometheus-operator

https://prometheus.io/docs/alerting/configuration/#email_config 


GOLDPINGER -  карта связанности кластера - 1:40
Мониторинг сертификатов через прометея
mrgreyves 
Vladimir D 


skydive.network умеет строить связность https://habr.com/ru/post/472724/ 