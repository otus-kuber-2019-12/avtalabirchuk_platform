# безопасность hashicorp vault username for assignee erlong15
## вывод helm status vault
    NAME: vault-helm-1581168473  
    LAST DEPLOYED: Sat Feb  8 16:27:54 2020  
    NAMESPACE: default  
    STATUS: deployed  
    REVISION: 1  
    TEST SUITE: None  
    NOTES:  
    Thank you for installing HashiCorp Vault!  

    Now that you have deployed Vault, you should look over the docs on using  
    Vault with Kubernetes available here:  

    https://www.vaultproject.io/docs/  

    Your release is named vault-helm-1581168473. To learn more about the release, try:  

    $ helm status vault-helm-1581168473  
    $ helm get vault-helm-1581168473  

## вывод    init --key-shares=1 --key-threshold=1
    Unseal Key 1: GMdySPFre0tLAijmivQX0qB9JVJZAWvTwo7NMBJ8MSM=  

    Initial Root Token: s.eDWBgpQ05Z2Tc8dpUPQleekM  

    Vault initialized with 1 key shares and a key threshold of 1. Please securely  
    distribute the key shares printed above. When the Vault is re-sealed,  
    restarted, or stopped, you must supply at least 1 of these keys to unseal it  
    before it can start servicing requests.  

    Vault does not store the generated master key. Without at least 1 key to  
    reconstruct the master key, Vault will remain permanently sealed!  

    It is possible to generate new unseal keys, provided you have a quorum of  
    existing unseal keys shares. See "vault operator rekey" for more information.  

## вывод после распечатывания подов
    Key             Value  
    ---             -----  
    Seal Type       shamir  
    Initialized     true  
    Sealed          false  
    Total Shares    1  
    Threshold       1  
    Version         1.3.1  
    Cluster Name    vault-cluster-cb23bb48  
    Cluster ID      f14d273c-9751-2312-72dd-30cb3d7f7a5c  
    HA Enabled      true  
    HA Cluster      https://10.4.2.8:8201  
    HA Mode         active  
## вывод vault login
    Token (will be hidden):   
    Success! You are now authenticated. The token information displayed below  
    is already stored in the token helper. You do NOT need to run "vault login"  
    again. Future Vault requests will automatically use this token.  

    Key                  Value  
    ---                  -----  
    token                s.eDWBgpQ05Z2Tc8dpUPQleekM  
    token_accessor       BU8jDjgH9FcGNbrvMi9EYgHf  
    token_duration       ∞  
    token_renewable      false  
    token_policies       ["root"]  
    identity_policies    []  
    policies             ["root"]  
## вывод vault auth list после ввода логина k exec -it vault-helm-1581168473-2 -- vault login
    Path      Type     Accessor               Description  
    ----      ----     --------               -----------  
    token/    token    auth_token_967be41f    token based credentials  
## вывод команды чтения
    kubectl exec -it vault-helm-1581168473-0 -- vault read otus/otus-ro/config  
    Key                 Value  
    ---                 -----  
    refresh_interval    768h  
    password            asajkjkahs  
    username            otus  

    kubectl exec -it vault-helm-1581168473-0 -- vault kv get otus/otus-rw/config  
    ====== Data ======  
    Key         Value  
    ---         -----  
    password    asajkjkahs  
    username    otus  
## вывод списка авторизаций после включение авторизации kubernetes
    k exec -it vault-helm-1581168473-0 -- vault auth list  
    Path           Type          Accessor                    Description  
    ----           ----          --------                    -----------  
    kubernetes/    kubernetes    auth_kubernetes_997998ce    n/a  
    token/         token         auth_token_967be41f         token based credentials
## почему выходили ошибки при записи по нашей политике
 - почему не происходила запись, в политике должны быть указаны capabilities - значение "update" можно почитать тут о всех задаваемых значениях https://www.vaultproject.io/docs/concepts/policies/
## установка кластера vault 
 - бекенд для волта это consul
 - установка consul
  - git clone https://github.com/hashicorp/consul-helm.git
  - helm install -g ../consul-helm -f --wait ./values.yaml
    - для работы по https: нужно использовать gossipEncryption (внутренний протокол consul)
  - установка vault
    - установка через helm
      - git clone https://github.com/hashicorp/vault-helm.git
      - helm install -g ./vault-helm -f ./vault-helm/values.yaml
    - генерация Useal and ROOT Token
      - k exec -it vault-helm-1581168473-0 -- vault operator init --key-shares=1 --key-threshold=1
      - проверить статус инициализации
        - k exec -it vault-helm-1581168473-0 -- vault status
    - посмотреть статус каждого пода
     - k exec -it vault-helm-1581168473-0 env | grep VAULT
       - VAULT_ADDR=http://127.0.0.1:8200 исходя из этого нужно распечатать каждый под
     - распечатка каждого пода k exec -it vault-helm-1581168473-{1,2,3} -- vault operator unseal 'GMdySPFre0tLAijmivQX0qB9JVJZAWvTwo7NMBJ8MSM=
    - посмотреть список доступных авторизаций
      - k exec -it vault-helm-1581168473-0 -- vault auth list (должна быть ошибка)
    - залогинется в vault с root login
      - k exec -it vault-helm-1581168473-2 -- vault login (используя логин полученный при инициализации)
## создание секретов
- kubectl exec -it vault-helm-1581168473-0 -- vault secrets enable --path=otus kv включить хранилище key-value
- kubectl exec -it vault-helm-1581168473-0 -- vault secrets list --detailed
- kubectl exec -it vault-helm-1581168473-0 -- vault kv put otus/otus-ro/config username='otus' password='asajkjkahs' положить секреты
- kubectl exec -it vault-helm-1581168473-0 -- vault kv put otus/otus-rw/config username='otus' password='asajkjkahs' положить секреты
- kubectl exec -it vault-helm-1581168473-0 -- vault read otus/otus-ro/config чтение
- kubectl exec -it vault-helm-1581168473-0 -- vault kv get otus/otus-rw/config чтение
## включение авторизации через k8s
    - kubectl exec -it vault-helm-1581168473-0 -- vault auth enable kubernetes
### создание сервис аккаунта
 - kubectl create serviceaccount vault-auth
 - применение ClusterRoleBinding
   - k apply -f ./vault-auth-service-account.yml
### подготовка переменных для записи в конфиг кубер авторизации
    export VAULT_SA_NAME=$(kubectl get sa vault-auth -o jsonpath="{.secrets[*]['name']}") # получаем ca name vault-auth-token-pgcfr  
    export SA_JWT_TOKEN=$(kubectl get secret $VAULT_SA_NAME -o jsonpath="{.data.token}" | base64 --decode; echo) # получаем jwt_token из SA_NAME и декодируем его  
    export SA_CA_CRT=$(kubectl get secret $VAULT_SA_NAME -o jsonpath="{.data['ca\.crt']}" | base64 --decode; echo) #SA ca cert из SA_NAME и тоже его декодируем  
    export K8S_HOST=$(more ~/.kube/config | grep server |awk '/http/ {print $NF}')  
        ### alternative way  
    export K8S_HOST=$(kubectl cluster-info | grep 'Kubernetes master' | awk '/https/ {print $NF}' | sed 's/\x1B\[[0-9;]*m//g' ) # задаем переменную нашего хоста где крутится волта  
#### записываем конфиг в vault
    kubectl exec -it vault-helm-1581168473-0 -- vault write auth/kubernetes/config \  
    token_reviewer_jwt="$SA_JWT_TOKEN" \  
    kubernetes_host="$K8S_HOST" \  
    kubernetes_ca_cert="$SA_CA_CRT"  
#### создаем фаил политики https://learn.hashicorp.com/vault/getting-started/policies
    otus-policy.hcl  
    - примняем политику
      - копируем созданный фаил kubectl cp otus-policy.hcl vault-helm-1581168473-0:/tmp/
      - применяем политику k exec -it vault-helm-1581168473-0 -- vault policy write otus-policy /tmp/otus-policy.hcl
      - выставляе параметры k exec -it vault-helm-1581168473-0 -- vault write auth/kubernetes/role/otus bound_service_account_names=vault-auth bound_service_account_namespaces=default policies=otus-policy ttl=24h
    - проверка 
      - создаем под
        - kubectl run --generator=run-pod/v1 tmp --rm -i --tty --serviceaccount=vault-auth --image alpine:3.7
        - устанавливаем пакеты apk add curl jq
      пробуем получить токен
        - VAULT_ADDR=http://vault-helm-1581168473:8200
        - KUBE_TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token) 
        - curl --request POST --data '{"jwt": "'$KUBE_TOKEN'", "role": "otus"}' $VAULT_ADDR/v1/auth/kubernetes/login | jq
        - TOKEN=$(curl -k -s --request POST --data '{"jwt": "'$KUBE_TOKEN'", "role": "test"}' $VAULT_ADDR/v1/auth/kubernetes/login | jq '.auth.client_token' | awk -F\" '{print $2}')
      - проверяем чтение из хранилища созданные в самом начале
        - curl --header "X-Vault-Token:s.ixZ8SaIAi6hhIt8uixJWAIh2" $VAULT_ADDR/v1/otus/otus-ro/config
        - curl --header "X-Vault-Token:s.ixZ8SaIAi6hhIt8uixJWAIh2" $VAULT_ADDR/v1/otus/otus-rw/config
      - проверяем запись
        - curl --request POST --data '{"bar": "baz"}' --header "X-Vault-Token:s.ixZ8SaIAi6hhIt8uixJWAIh2" $VAULT_ADDR/v1/otus/otus-ro/config
        - curl --request POST --data '{"bar": "baz"}' --header "X-Vault-Token:s.ixZ8SaIAi6hhIt8uixJWAIh2" $VAULT_ADDR/v1/otus/otus-rw/config
        - curl --request POST --data '{"bar": "baz"}' --header "X-Vault-Token:s.ixZ8SaIAi6hhIt8uixJWAIh2" $VAULT_ADDR/v1/otus/otus-rw/config1
      - почему не происходила запись, в политике должны быть указаны capabilities - значение "update" можно почитать тут https://www.vaultproject.io/docs/concepts/policies/
## Use case использования авторизации через кубер


- пример создания секретов ил литерала
 - kubectl -n test-v1 create secret generic dev-db-secret --from-literal=username=devuser --from-literal=password='S!B\*d$zDsb'
- пример создания секретов из файла
 - kubectl create secret generic db-user-pass --from-file=./username.txt --fromfile=./password.txt
- пример создания сертификата tls
 - kubectl create secret tls vault-certs --cert=vault.crt --key=vault_gke.key

- установка ingress
 - kubectl create ns nginx-ingress
 - helm upgrade --install nginx-ingress stable/nginx-ingress --wait --namespace=nginx-ingress --version=1.17.1


   
- создавать секреты и политики
- настройка авторизации через kubernetes sa
- 

- лайфхаки
 - посмотреть все переменные контейнера можно следующим образом
   - смотрим pid запущенного контейнера ps aux | grep postgres
   - заходим в sudo less /proc/13270/environ и видим все переменные которые были заданы при запуске, касается всех докеров! 
 - убрать все коментарии из файла 
   - cat ~/projects/vault-helm/values.yaml | egrep -v '^\s*#|^$' 
- полездные материалы how to hashicorp consul, vault, vagrant, terraform, nomad, packer
  - https://learn.hashicorp.com/
-  в каждом поде кубер загружает свой ca который находится тут
 - /var/run/secrets/kubernetes.io/serviceaccount/ca.crt 
SSL/TLS: терминология
 - SSL - Secure Socket Layer
 - TLS - Transport Layer Security (актуальная версия 1.3)
 - PKI - Public Key Infrastructure
 - CA - certificate authorities
 - Intermediate certificate
 - CRL - Certificate Revocation List

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