# безопасность hashicorp vault username for assignee erlong15
- установка кластера vault 
- создавать секреты и политики
- настройка авторизации через kubernetes sa
- 

- полездные материалы how to hashicorp consul, vault, vagrant, terraform, nomad, packer
  - https://learn.hashicorp.com/
Обновление сертификатов кластера и что делать если они протухли
- https://habr.com/ru/company/southbridge/blog/465733/
- добавить сертификаты в kubernetes
 - kubectl create secret tls CERTNAME  --key /tmp/privat.key --cert /tmp/certificate.crt --namespace MY-NAMESPACE
 - проверить сертификат
  - kubectl describe secret CERTNAME --namespace MY-NAMESPACE
- установить default сертификат для ingress controlle
    - https://success.docker.com/article/how-to-configure-a-default-tls-certificate-for-the-kubernetes-nginx-ingress-controller

lesson 13 Хранилище секретов для приложений. Vault
Сергей Рязанцев
    hashicorp Vault

создание секретов 
- kubectl create secret docker-registry
посмотреть секреты
 - k get secret 

 Дырка Etcd кто имеет доступ может посмотреть секреты
 хранение секретов в  других провайдеров
 - cert публичный ключь
 - key приватный ключ

база по TLS сертификатам


cat ~/projects/vault-helm/values.yaml | egrep -v '^\s*#|^$' 

consul-helm
- https://github.com/hashicorp/consul-helm.git 

vault helm
- https://github.com/hashicorp/vault-helm.git 

https://github.com/hashicorp/vault-helm.git 
/var/run/secrets/kubernetes.io/serviceaccount/ca.crt 

работает http / https по одному порту

практики от hashicorp 
- https://learn.hashicorp.com 
распечатка волта 
 - 
auto unseal - автоматизация распечатки волта
домашка 1:44

обьяснение 33 слайд - что моэно делать