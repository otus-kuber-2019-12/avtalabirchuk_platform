
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
prometheus Thanos - sidecar (контейнер)

у minio есть distributed mode - вроде это как раз к HA относится. 
https://docs.min.io/docs/distributed-minio-quickstart-guide.html 
- установка через зельм слайд 52 из 79 время 1:15
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