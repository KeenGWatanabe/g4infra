# Everytime you access repo
```
$ git pull origin main
```

# Set your terraform tfvars environment

```
terraform workspace new dev (create this once in your local)
terraform workspace select dev
  terraform apply -var-file="dev.tfvars"
```