# Lesson 10 Log логирование
- инструменты
  слайд 9
- ELK
  Ротация логов elastic  время 20 26 есть ссылка, слайд 29 ( называется Куратор)
  кидать в эластик на прямую слайд 33

  Если шарды не реплицированы то все потеряется нахуй
  типы данные ipv4 ipv6 слайд 44
  CRUD - create read update delete 
  класть информацию в python слайд 51-52
    значения post для создания put для обновления
    GET - insernt update
    DELETE
    Документ - это вроде json

LOGSTASH - слайд 62
PAGeRDUTY - алертинг по логам
BEATs - фрейморк для разработки агенты на пограничные сервера...
Fluentd - менее требовательный чем logstash
Ingest API -  заменяет функционал fluentd logstash
Grok - с спомощью регулярок дает возможность разделять поля... которые потом отправляются в elastic https://github.com/logstash-plugins/logstash-patterns-core/tree/master/patterns  парсить шаблон можно тут https://grokdebug.herokuapp.com/patterns# 

CloudWatch
Установка fluentD через операторов HELM - https://banzaicloud.com/blog/k8s-logging-elasticsearch/ 

PAGERduty и OPSJENY - алертинг
практику дослушать после 2 часов