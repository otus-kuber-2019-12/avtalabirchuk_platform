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
## получить index.html из пода kubernetes auth
/ $ cat /etc/secrets/index.html   
  <html>  
  <body>  
  <p>Some secrets:</p>  
  <ul>  
  <li><pre>username: otus</pre></li>  
  <li><pre>password: asajkjkahs</pre></li>  
  </ul>  
    
  </body>  
  </html> 

## выдача запроса на сертифкат
  kubectl exec -it vault-helm-1581168473-0 -- vault write pki_int/issue/example-dot-ru common_name="gitlab.example.ru" ttl="24h"  
  ```
    Key                 Value
    ---                 -----
    ca_chain            [-----BEGIN CERTIFICATE-----
    MIIDnDCCAoSgAwIBAgIUMBPxlP0BjJ6MZIAdoNNCUnFbEFkwDQYJKoZIhvcNAQEL
    BQAwFTETMBEGA1UEAxMKZXhtYXBsZS5ydTAeFw0yMDAyMDkxNDU3NThaFw0yNTAy
    MDcxNDU4MjhaMCwxKjAoBgNVBAMTIWV4YW1wbGUucnUgSW50ZXJtZWRpYXRlIEF1
    dGhvcml0eTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAL+v14y4PSTG
    h2NcuFCSnoNrCR/9Jf9nhRmX2KPnKeV8xAzGrd1HXwrNwrTY2wpE4f3XOBQqxqVA
    C+hPKyDNDgZ361/C/Sel6XmyDplPVxp6jVkzKKFfafhpOjenjs6Z5EvWYiK6aLL1
    vayuNoBIM5+dhQaozMXOTBrrvG9tVqZh61N2AOHog59JGli0E1xcVU6wu8FWp503
    2bDDuKZzZadEpihSJ1mdqmn3xtRHlzEYAPdTYRgPcwYGPIawfedfUp2AjuxWcs4f
    3NMPau4oBk1I/4rEkJOUP2IQm6djQEd+w01jsOMIZb2fz9CeoUyRLxPypjIQXlLT
    Uup3IAkP2FkCAwEAAaOBzDCByTAOBgNVHQ8BAf8EBAMCAQYwDwYDVR0TAQH/BAUw
    AwEB/zAdBgNVHQ4EFgQUKY1jWooBW8pGP36w/JyEWFQWikIwHwYDVR0jBBgwFoAU
    ics3JtjAa/vXbGiFRPLCRwV5v0IwNwYIKwYBBQUHAQEEKzApMCcGCCsGAQUFBzAC
    hhtodHRwOi8vdmF1bHQ6ODIwMC92MS9wa2kvY2EwLQYDVR0fBCYwJDAioCCgHoYc
    aHR0cDovL3ZhdWx0OjgyMDAvdjEvcGtpL2NybDANBgkqhkiG9w0BAQsFAAOCAQEA
    UZoVNeuSllMj/gZDpmiYdj8LfsEGyEEJRSngCbvdMXtciNgsl3ukhciueYWHQmp1
    cNmAC7qDhadabJW9v8ZDmO9RR9HRw9X3MDa4wuAxAqevq73aWKC0vi1cPeyrX+P3
    6Msma4YFrffba7FUdvCW8yfbBgisz7FsTBuhWcuxV/yxHFakiOh8AM6ewkjxIddu
    ULSkmT4XYkY2nLAlT+AT8BKNupKFiCmb3BkS0mRS2/EhtD2Mu1LnmUIb4BOur/65
    bCFM89CkxacwxukrEU0vrompOMomLHXnszZOW+5+4oVEv0IotfCuTyZupauyULcp
    4AJ3v9WQyWYf1rB7CXz6Xg==
    -----END CERTIFICATE-----]`
    certificate         -----BEGIN CERTIFICATE-----
    MIIDZzCCAk+gAwIBAgIUPBgsSoM2F4J17Nv9kGVKWIw0g5EwDQYJKoZIhvcNAQEL
    BQAwLDEqMCgGA1UEAxMhZXhhbXBsZS5ydSBJbnRlcm1lZGlhdGUgQXV0aG9yaXR5
    MB4XDTIwMDIwOTE1MDgwOVoXDTIwMDIxMDE1MDgzOVowHDEaMBgGA1UEAxMRZ2l0
    bGFiLmV4YW1wbGUucnUwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDw
    IiHBWZGnYQrypBktHqWo9JPB0pbhFSrNB/a1CqV32r0kKCydyYzLiHcL5WsER6k+
    bBVSwxKXsPitNjtVhSOFXsig4kJnpJGNk2DGlondFnfks92+0SuwLItjfUVBNaAb
    k+nC4HiyfkArmlbGVICG5G2rEhLBw0UzbJLZfKy0kUFDWT44X0aGuyLu7mrmoHwK
    loOYDppT5MGBaTYOlIdDpZiqy1wY43q+eYJ7M6pIy7XtI6WzOgQXfFwBxzu1KLKf
    z3HZHM9ohtYCdolHUw3bOA4NEPA/9FBmabo+w/BEd5/1h+v4HIb1KN3C2u+Kvxyh
    EwtrRGT10URFKuddY6vzAgMBAAGjgZAwgY0wDgYDVR0PAQH/BAQDAgOoMB0GA1Ud
    JQQWMBQGCCsGAQUFBwMBBggrBgEFBQcDAjAdBgNVHQ4EFgQUi0Ir45UWf/EwJ7Je
    WUhCmdGKfN4wHwYDVR0jBBgwFoAUKY1jWooBW8pGP36w/JyEWFQWikIwHAYDVR0R
    BBUwE4IRZ2l0bGFiLmV4YW1wbGUucnUwDQYJKoZIhvcNAQELBQADggEBAILixtJU
    a1RaZtIyYy9DqLBtlW9CDawYHw+4U1dwTqscAq44Zyh7xMQ+ZzU26lf+dP3vhL0y
    tAnGogZa0LgAL02cmHRBkpwgtck/XUkk3rAlqbbY30bg/lBgZ8Ioy5JO/js4C29F
    3d/hpjRogOs1+tIDxLSp9aeoH7s3dFLb0ujGdU41FGAbZvMeOSq5WBmJbR+VdZYW
    09SbrkhYa17hkjokUBtf5A8ryp49lgQaZ2O7sHTspNc/IFHQ9wT+rvEKPhaPU1V2
    JwNy/WROibtuJJFNMRVKEQ3Ey26FlLXCwULLPj0SRPybJfI9vjE/h7assqGaaVeK
    Z8aRnvMD/d7EDj0=
    -----END CERTIFICATE-----
    expiration          1581347319
    issuing_ca          -----BEGIN CERTIFICATE-----
    MIIDnDCCAoSgAwIBAgIUMBPxlP0BjJ6MZIAdoNNCUnFbEFkwDQYJKoZIhvcNAQEL
    BQAwFTETMBEGA1UEAxMKZXhtYXBsZS5ydTAeFw0yMDAyMDkxNDU3NThaFw0yNTAy
    MDcxNDU4MjhaMCwxKjAoBgNVBAMTIWV4YW1wbGUucnUgSW50ZXJtZWRpYXRlIEF1
    dGhvcml0eTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAL+v14y4PSTG
    h2NcuFCSnoNrCR/9Jf9nhRmX2KPnKeV8xAzGrd1HXwrNwrTY2wpE4f3XOBQqxqVA
    C+hPKyDNDgZ361/C/Sel6XmyDplPVxp6jVkzKKFfafhpOjenjs6Z5EvWYiK6aLL1
    vayuNoBIM5+dhQaozMXOTBrrvG9tVqZh61N2AOHog59JGli0E1xcVU6wu8FWp503
    2bDDuKZzZadEpihSJ1mdqmn3xtRHlzEYAPdTYRgPcwYGPIawfedfUp2AjuxWcs4f
    3NMPau4oBk1I/4rEkJOUP2IQm6djQEd+w01jsOMIZb2fz9CeoUyRLxPypjIQXlLT
    Uup3IAkP2FkCAwEAAaOBzDCByTAOBgNVHQ8BAf8EBAMCAQYwDwYDVR0TAQH/BAUw
    AwEB/zAdBgNVHQ4EFgQUKY1jWooBW8pGP36w/JyEWFQWikIwHwYDVR0jBBgwFoAU
    ics3JtjAa/vXbGiFRPLCRwV5v0IwNwYIKwYBBQUHAQEEKzApMCcGCCsGAQUFBzAC
    hhtodHRwOi8vdmF1bHQ6ODIwMC92MS9wa2kvY2EwLQYDVR0fBCYwJDAioCCgHoYc
    aHR0cDovL3ZhdWx0OjgyMDAvdjEvcGtpL2NybDANBgkqhkiG9w0BAQsFAAOCAQEA
    UZoVNeuSllMj/gZDpmiYdj8LfsEGyEEJRSngCbvdMXtciNgsl3ukhciueYWHQmp1
    cNmAC7qDhadabJW9v8ZDmO9RR9HRw9X3MDa4wuAxAqevq73aWKC0vi1cPeyrX+P3
    6Msma4YFrffba7FUdvCW8yfbBgisz7FsTBuhWcuxV/yxHFakiOh8AM6ewkjxIddu
    ULSkmT4XYkY2nLAlT+AT8BKNupKFiCmb3BkS0mRS2/EhtD2Mu1LnmUIb4BOur/65
    bCFM89CkxacwxukrEU0vrompOMomLHXnszZOW+5+4oVEv0IotfCuTyZupauyULcp
    4AJ3v9WQyWYf1rB7CXz6Xg==
    -----END CERTIFICATE-----
    private_key         -----BEGIN RSA PRIVATE KEY-----
    MIIEpAIBAAKCAQEA8CIhwVmRp2EK8qQZLR6lqPSTwdKW4RUqzQf2tQqld9q9JCgs
    ncmMy4h3C+VrBEepPmwVUsMSl7D4rTY7VYUjhV7IoOJCZ6SRjZNgxpaJ3RZ35LPd
    vtErsCyLY31FQTWgG5PpwuB4sn5AK5pWxlSAhuRtqxISwcNFM2yS2XystJFBQ1k+
    OF9Ghrsi7u5q5qB8CpaDmA6aU+TBgWk2DpSHQ6WYqstcGON6vnmCezOqSMu17SOl
    szoEF3xcAcc7tSiyn89x2RzPaIbWAnaJR1MN2zgODRDwP/RQZmm6PsPwRHef9Yfr
    +ByG9Sjdwtrvir8coRMLa0Rk9dFERSrnXWOr8wIDAQABAoIBAQCDZsn92ZuAcfPh
    rrYwIHMaLyujhi8V39VZ+J+hlb/SBBo37NvtQ9sNjRFHqzSSVPxhshdBAInuA+Mw
    NVrmg0JauvEiSG159W3IgPsV8E5kcuUMevg+cIttjhKAUI5TDpscPCZQgzDIy5kl
    wwD06kyig+EXGX62FLqLV0BMTpLbAwnNGidgpSKA8Wp0AQ1kI0f/cVjDA7BiZc5U
    g37K4fXW7k15pUuJ4rxzM4sq9KwhuBxl/Oe26tObu2f8DY3ZcwVK4V2MU4BSORUY
    lCYG/mRYPoBjAhrrqrjIdiDHsky6a7jfcTVxMgICafFXvcVwOZT+CFz88BzQ5Ya7
    MH161AahAoGBAPXTR7dC4v7jyPV2nJb4vCyqSBof4rxx4du00oKWVlnppcfQdjCj
    Cn5nk3avjYRS/ncJxLj9ga9IIbnjGDsBQtrVxA9OUdXrpDePgBabIPqornZDpUak
    0YsSYJ/Vh/Dkkd7lYNMSumNLEQ1ABCEQiKsCNN+pbYmhsSigHE8JGf8ZAoGBAPoS
    il0mevVJWC0soHSQpO8HuPWcANcdbj2oQU0hO9hIev6VEdhyGuZlbr7INZwOadlD
    nd+0bmbH2fUHrCXmu1l0BWoC3mpHGAxTr/GsF7l2VSnX78vUWJshpUxlW4vtEJNl
    qCPqOie+n6WrEEbyQqCuHsf3XrfM5EakTk7sCoDrAoGBAL8+0ipm5QZ73BnrX0Os
    22i8ST/Z0qHcz2QIN0XVA/ULaygaq/iGv2E732OUjDqH/uRJOzzYLI5bRbHCVVWC
    U6rAZ7moqs4Md0OqZnIv2eZoWOI1Gl3tWAAkGfv/ObVVfY61UTCk/1DEU83FIfE/
    VbQFEXF39HoAyzzZ42wxnoHxAoGAShkSTJWpW2L3MLOHe+KcLIOSR5yJFzSORNDF
    QLB3Rhf78dGD7ymoVNp7XSZ/1BTlQk5pyi5xhBz1tUgntzdODix1qjrdYopcUtK9
    UJPYl8i7ZWGpmTD7bEQk8aUa4jRFdBdsIfA2eS5fqbwtX4hLO8c8Ma5Xr4iTn2by
    GSqR1i8CgYA+JurP2jxVKu551xKY2qcc0KTLPV88WXNpCwIXIettXnjLJEzfGiFc
    /G74RFXjM4pv9gimnSEgdi00kdgEaTERSUCi7qOqcfzC+omo5BuZqjrWueQAz0U+
    lMivm7WeA88+ogxCw3QwBRyt9QadNdVV94qQORloprN0Ew4zGRiijQ==
    -----END RSA PRIVATE KEY-----
    private_key_type    rsa
    serial_number       3c:18:2c:4a:83:36:17:82:75:ec:db:fd:90:65:4a:58:8c:34:83:91
  ```
## установка кластера vault 
 - бекенд для волта это consul
 - установка consul
  - git clone https://github.com/hashicorp/consul-helm.git
  - helm install consul consul-helm
    - для работы по https: нужно использовать gossipEncryption (внутренний протокол consul)
  - установка vault
    - установка через helm
      - git clone https://github.com/hashicorp/vault-helm.git
      - helm install vault ./vault-helm -f ./vault-helm/values.yaml
    - генерация Useal and ROOT Token
      - k exec -it vault-helm-1581168473-0 -- vault operator init --key-shares=1 --key-threshold=1
      - проверить статус инициализации
        - k exec -it vault-helm-1581168473-0 -- vault status
    - посмотреть статус каждого пода
     - k exec -it vault-helm-1581168473-0 env | grep VAULT
       - VAULT_ADDR=http://127.0.0.1:8200 исходя из этого нужно распечатать каждый под
     - распечатка каждого пода k exec -it vault-helm-1581168473-{1,2,3} -- vault operator unseal 'GMdySPFre0tLAijmivQX0qB9JVJZAWvTwo7NMBJ8MSM='
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

    - прочитать полученный конфиг k exec -it vault-helm-1581168473-0 -- vault read auth/kubernetes/config
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
        ### для использования по https:
         - VAULT_ADDR=https://vault-helm-1581168473:8200
         - curl --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt  --request POST --data '{"jwt": "'$KUBE_TOKEN'", "role": "otus"}' $VAULT_ADDR/v1/auth/kubernetes/login | jq

      - проверяем чтение из хранилища созданные в самом начале
        - curl --header "X-Vault-Token:s.ixZ8SaIAi6hhIt8uixJWAIh2" $VAULT_ADDR/v1/otus/otus-ro/config
        - curl --header "X-Vault-Token:s.ixZ8SaIAi6hhIt8uixJWAIh2" $VAULT_ADDR/v1/otus/otus-rw/config
      - проверяем запись
        - curl --request POST --data '{"bar": "baz"}' --header "X-Vault-Token:s.ixZ8SaIAi6hhIt8uixJWAIh2" $VAULT_ADDR/v1/otus/otus-ro/config
        - curl --request POST --data '{"bar": "baz"}' --header "X-Vault-Token:s.ixZ8SaIAi6hhIt8uixJWAIh2" $VAULT_ADDR/v1/otus/otus-rw/config
        - curl --request POST --data '{"bar": "baz"}' --header "X-Vault-Token:s.ixZ8SaIAi6hhIt8uixJWAIh2" $VAULT_ADDR/v1/otus/otus-rw/config1
      - почему не происходила запись, в политике должны быть указаны capabilities - значение "update" можно почитать тут https://www.vaultproject.io/docs/concepts/policies/
## Use case использования авторизации через кубер
- пример, правим конфиги
  - /home/andrew/kubernetis/github-otus/avtalabirchuk_platform/kubernetes-vault/vault-guides/identity/vault-agent-k8s-demo/configs-k8s
    - my-vault-agent-config.hcl
    - my-vault-agent-config.hcl
    - # Create a ConfigMap, example-vault-agent-config
    - kubectl create configmap example-vault-agent-config --from-file=./configs-k8s/
    - View the created ConfigMap
    - kubectl get configmap example-vault-agent-config -o yaml
    - Finally, create vault-agent-example Pod
    - kubectl apply -f example-k8s-spec.yml --record
## создадим CA на базе vault
 - включаем pki secrets
  - kubectl exec -it vault-helm-1581168473-0 -- vault secrets enable pki
   - проверяем
    - k exec -it vault-helm-1581168473-0 -- vault secrets list
  - kubectl exec -it vault-helm-1581168473-0 -- vault secrets tune -max-lease-ttl=87600h pki
  - kubectl exec -it vault-helm-1581168473-0 -- vault write -field=certificate pki/root/generate/internal common_name="example.ru" ttl=87600h > CA_cert.crt
- пропишем урлы для ca и отозванных сертификатов
 - kubectl exec -it vault-helm-1581168473-0 -- vault write pki/config/urls issuing_certificates="http://vault-helm-1581168473:8200/v1/pki/ca" crl_distribution_points="http://vault-helm-1581168473:8200/v1/pki/crl"
- создадим промежуточный сертификат
 - kubectl exec -it vault-helm-1581168473-0 -- vault secrets enable --path=pki_int pki
 - kubectl exec -it vault-helm-1581168473-0 -- vault secrets tune -max-lease-ttl=87600h pki_int
 - kubectl exec -it vault-helm-1581168473-0 -- vault write -format=json pki_int/intermediate/generate/internal common_name="example.ru Intermediate Authority" | jq -r '.data.csr' > pki_intermediate.csr
- прописываем промежуточный сертификат
 - kubectl cp pki_intermediate.csr vault-helm-1581168473-0:/tmp/
 - kubectl exec -it vault-helm-1581168473-0 -- vault write -format=json pki/root/sign-intermediate csr=@/tmp/pki_intermediate.csr format=pem_bundle ttl="43800h" | jq -r '.data.certificate' > intermediate.cert.pem
 - kubectl cp intermediate.cert.pem vault-helm-1581168473-0:/tmp
 - kubectl exec -it vault-helm-1581168473-0 -- vault write pki_int/intermediate/set-signed certificate=@/tmp/intermediate.cert.pem
- Создадим и отзовем новые сертификаты
 - создаем роль для новых сертификатов
  - kubectl exec -it vault-helm-1581168473-0 -- vault write pki_int/roles/example-dot-ru allowed_domains="example.ru" allow_subdomains=true max_ttl="720h"
 - создаем сертификат
  - kubectl exec -it vault-helm-1581168473-0 -- vault write pki_int/issue/example-dot-ru common_name="gitlab.example.ru" ttl="24h"
 - отзываем сертификат
  - kubectl exec -it vault-helm-1581168473-0 -- vault write pki_int/revoke serial_number="01:26:a5:78:c6:31:12:c5:f5:c6:b8:db:0d:6a:83:0a:a9:10:b3:ae"

# включаем TLS
1) меняем параметры в values.yaml
 -   extraEnvironmentVars: {}
       VAULT_ADDR: https://localhost:8200
       VAULT_CACERT: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt 
-   extraVolumes: []
    - type: secret
      name: vault-certs
      path: null # default is `/vault/userconfig`
 - проверка
   - curl https://10.1.9.26:8200/ui/vault/auth

   
(sed 's/\x1b\[[0-9;]*m//g')

# включаем работу с сертификатами время 2.16.21 nginx
 - kubectl exec -it vault-helm-1581168473-0 -- vault secrets enable pki
   - kubectl exec -it vault-helm-1581168473-0 -- vault path-help pki
- настройки все можно посмотреть на "vault secrets engine pki"






- пример получения секретов из vault
  - k exec -it vault-helm-1581168473-0 -- vault secrets list
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