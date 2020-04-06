настройка terraform - https://learn.hashicorp.com/terraform/gcp/build
Project ID - 
Включить google api in project - https://console.developers.google.com/apis/library/compute.googleapis.com?pli=1&project=my-firstproject-terraform&folder&organizationId
 - https://console.developers.google.com/apis/api/compute.googleapis.com/landing?project=rare-host-271912&authuser=3
 - создать новый сервис аккаунт
  - https://console.cloud.google.com/apis/credentials/serviceaccountkey?authuser=3&project=rare-host-271912
        ```Select the project you created in the previous step.
        Under "Service account", select "New service account".
        Give it any name you like.
        For the Role, choose "Project -> Editor".
        Leave the "Key Type" as JSON.
        Click "Create" to create the key and save the key file to your system.```
 - сохраняем ключ в нужном месте
 - описанная документация terraform по всем поддерживаемым api https://www.terraform.io/docs/providers/index.html
 - применение команд
  - terraform apply
  - terraform show
 - уничтожить инфраструктуру Destroy
  - terraform destroy
 - Resource Dependencies
  - terraform plan (что будет создано)
  - terraform plan -out static_ip
  - terraform apply "static_ip"
  - terraform taint (пометить ресурс на удаление и при инициализации терраформ создаст новый ресурс)
 - Input Variables
  - terraform plan -var 'project=<PROJECT_ID>'
  - не важно какой фаил ты создаешь, главное, чтобы было удобно читать твой проект к примеру variables.tf
  - пример использования переменных секретов в файле(добавить эти файли в .gitignore)
    ```terraform apply \
    -var-file="secret.tfvars" \
    -var-file="production.tfvars"```
    - определить переменную как строку
      ```variable "project" {
         type = string
      }```
    - определить переменную как integer or float
      ```variable "web_instance_count" {
         type    = number
         default = 1
      }```
    - списки
      `variable "cidrs" { default = [] }`
      ```cidrs = [ "10.0.0.0/16", "10.1.0.0/16" ]```
    - Maps(Карты, словари)
      ```variable "environment" {
        type    = string
        default = "dev"
        }

        variable "machine_types" {
        type    = map
        default = {
            dev  = "f1-micro"
            test = "n1-highcpu-32"
            prod = "n1-highcpu-32"
        }
        }```
    - можно переопределять или применять переменные словарей 
      - terraform apply -var 'machine_types={ dev = "f1-micro", test = "n1-standard-16", prod = "n1-standard-16" }'

      