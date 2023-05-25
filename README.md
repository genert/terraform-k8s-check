# Terraform "check" exploration

Terraform 1.5 has introduced a "check {}" block that can be used to define assettions based on data source values to verify the state of the infastructure on an ongoing basis.

```
brew install tfenv colima
colima start --with-kubernetes
tfenv install 1.5.0-beta2
tfenv use 1.5.0-beta2
terraform init
terraform apply
```
