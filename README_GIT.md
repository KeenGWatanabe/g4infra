# Everytime you access repo
```
$ git pull origin main
```

# Set your terraform tfvars environment
```
terraform workspace select dev
  terraform apply -var-file="dev.tfvars"
```