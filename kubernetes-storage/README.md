# установка StorageClass для CSI Host Path Driver
 ## [описана установка в документации](https://github.com/kubernetes-csi/csi-driver-host-path/blob/master/docs/deploy-1.17-and-later.md)
 - выполняем скрипт 
   - ./snapshotter
   - устанавливаем host path driver
     - клонируем [репозиторий](https://github.com/kubernetes-csi/csi-driver-host-path)
     - запускаем deploy
       - переключаемся на [релизную](https://github.com/kubernetes-csi/csi-driver-host-path/releases) ветку git checkout 
       - запускаем deploy deploy/kubernetes-1.17/deploy.sh
       - смотрим получившиеся pods kubectl get pods
    - создаем storageClass `k apply -f storage-class.yaml`
    - создаем обьект PVC `k apply -f storage-pvc.yaml`
    - создаем обьект Pod ` k apply -f storage-pod.yml`
    - создаем снапшотер наих данных `k apply -f snapsshot.yaml`
    - для восстанвления используем `k apply -f restore.yaml`
## задание 
 - Создать StorageClass для CSI Host Path Driver
 - Создать объект PVC c именем storage-pvc
 - Создать объект Pod c именем storage-pod
 - Хранилище нужно смонтировать в /data



### описание из лекции важно:
 - нативное
   - hostPath
   - local
   - configMap
   - secret
   - downwardAPI
   - projected
   - gitRepo (deprecated)
 - облачное
   - awsElasticBLOCKStore
   - azureDisk
   - azureFile
   - gcePersistentDisk
 - Ceph
   - rbd - Rados Block Device
   - cephfs - CephFS
- Анатолий Капитула анатолмия катастрофы(посмотреть)
 - enterprice
  - iscsi
  - fc
  - cinder - OpenStack Cinder Volumes
  - vsphereVolume
  - scaleIO
 - сетевые ФС
  - glusterfs
  - nfs
 - новинки
  - flocker
  - portworxVolume
  - quobyte
  - storageos
 - расширения
  - flexVolume
  - csi
 - subPath

 vagrant up
 vagrant ssh -c 'cat /home/vagrant/.kube/config' > ~/.kube/config
 vagrant ssh 
  byobu