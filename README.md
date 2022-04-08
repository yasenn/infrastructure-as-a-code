# infrastructure-as-a-code-example
Examples of infrastructure as code tools include Yandex Cloud, Terraform and Ansible.
Terraform code don`t use managed service in Yandex Cloud.

## Install YC cli
```
curl https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash
```

## Init YC cli
```
yc init
```

## Get token, cloud-id, folder-id
```
yc config list
```
Output:
```
token: xxx
cloud-id: xxx
folder-id: xxxx
compute-default-zone: ru-central1-b
```

### terraform fmt for private.auto.tfvars.example
find . -iname 'private.auto.tfvars.example' -execdir mv -i '{}' private.auto1.tfvars \;
terraform fmt -recursive
find . -iname 'private.auto1.tfvars' -execdir mv -i '{}' private.auto.tfvars.example \;

