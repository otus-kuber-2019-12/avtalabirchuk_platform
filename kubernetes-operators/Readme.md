Lesson 8 kubernetes-operator
  - Создаем обьект типа MYSQL в API
  - CustomREsourceDefinition - это ресурс для определния других ресурсов (CRD)
    - avtalabirchuk_platform/kubernetes-operators/deploy/crd.yml
 ## взаимодейсвтие с обьектами
  - kubectl get crd
  - kubectl get mysqls.otus.homework
  - kubectl describe mysqls.otus.homework mysql-instance
  - kubectl describe jobs.batch restore-mysql-instance-job
  - удобный вариант получения имени пода
    - export MYSQLPOD=$(kubectl get pods -l app=mysql-instance -o jsonpath="{.items[*].metadata.name}")
    - echo $MYSQLPOD
    - kubectl exec -it $MYSQLPOD bash
## сделать обязательно поле к заполнению required
 - https://stackoverflow.com/questions/49822794/kubernetes-custom-resource-definition-required-field
 - необходимо указать значение required в виде списка значения которые обязательны
   - avtalabirchuk_platform/kubernetes-operators/deploy/crd.yml
# Оператор включает в себя CustomResourceDefinition и сustom сontroller
# Почему мы видим, что было создано до того момента как запустили оператора. В этом и суть вся оператора, он нам показывает все созданные обьекты если мы его запускаем первый раз
# Получить поды по имени export MYSQLPOD=$(kubectl get pods -l app=mysql-instance -o jsonpath="{.items[*].metadata.name}")