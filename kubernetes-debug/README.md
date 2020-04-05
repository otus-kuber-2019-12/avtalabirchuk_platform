# Lesson - 24 Kubernetes debug
## включение strace [полездная статья:](https://radu-matei.com/blog/state-of-debugging-microservices-on-k8s/) и [вторая](https://kirshatrov.com/2018/04/13/debugging-ruby-in-kubernetes/)
 - для решения проблемы с запуском strace нужно добавить директиву к deployment и обновить [image_образа](https://hub.docker.com/r/aylei/debug-agent/tags)
    ```securityContext:
    capabilities:
    add:
    - SYS_PTRACE
    - SYS_ADMIN```
## iptables-tailer https://github.com/box/kube-iptables-tailer
 - Тестовое приложение
   - [netperf-operator](https://github.com/piontec/netperf-operator) запускаем поды, проверки скорости общения по сети между нодами и подами
        ```kubectl apply -f ./deploy/crd.yaml
        kubectl apply -f ./deploy/rbac.yaml
        kubectl apply -f ./deploy/operator.yaml
        kubectl apply -f ./deploy/cr.yaml```
   - смотрим скорость и логи
     - kubectl describe netperf.app.example.com/example
 - iptables-tailer | Сетевые политики
   - применяем политику calico ограничивающее общение netperf-role == "netperf-client"
   - должны появиться логи на ноде 
     ```
        iptables --list -nv | grep DROP - счетчики дропов ненулевые
        iptables --list -nv | grep LOG - счетчики с действием логирования ненулевые
        journalctl -k | grep calico
     ```
 - iptables-tailer to the rescue!
   - запускаем манифест /kit/iptables/iptables-tailer.yml
   - логи запущенного пода
    -  k logs -n kube-system kube-iptables-tailer-xzpss
      ```
      E0330 06:51:04.510763       1 locator.go:180] Unable to resolve address: ip=10.28.1.61, error=lookup 61.1.28.10.in-addr.arpa. on 10.95.0.10:53: no such host
      ```
    - посмотреть логи кластера `kubectl get events -A`
    - посмотреть логи пода, где наблюдаем проблему `kubectl describe pod --selector=app=netperf-operator`
    ```
    Warning  PacketDrop  24m                  kube-iptables-tailer                               Packet dropped when receiving traffic from 10.28.1.63 
    Warning  PacketDrop  5m25s (x6 over 21m)  kube-iptables-tailer                               Packet dropped when receiving traffic from netperf-client-4a40ab6d2cc3 (10.28.1.63)
    ```
    - задание со * Исправьте ошибку в нашей сетевой политике, чтобы Netperf снова начал работать
      - нужно указать label из pod в политике allow
      ```
          - action: Allow
            source:
              selector: netperf-type == "client"
      ```
    - задание со * Поправьте манифест DaemonSet из репозитория, чтобы в логах отображались имена Podов, а не их IP-адреса
    - [в описании указаны директивы](https://github.com/box/kube-iptables-tailer)
      - POD_IDENTIFIER: (string, default: namespace) How to identify pods in the logs. name, label or namespace are currently supported. If label, uses the value of the label key specified by POD_IDENTIFIER_LABEL.
       - нужно поменять в daemonSet POD_IDENTIFIER_LABEL="name"
      - и логи видно в таком формате
      ```
      kubectl describe pod --selector=app=netperf-operator
      Warning  PacketDrop  5m25s (x6 over 21m)  kube-iptables-tailer                               Packet dropped when receiving traffic from netperf-client-4a40ab6d2cc3 (10.28.1.63)
      ```
      - где указано что трафик не проходит от пода netperf-client-4a40ab6d2cc3 (10.28.1.63)


