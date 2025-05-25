# Everytime you access repo
```
$ git pull origin main
```

# Set your terraform tfvars environment

```
terraform workspace new dev (create this once in your local)
terraform workspace select dev
  terraform plan -var-file=dev.tfvars
  terraform apply -var-file=dev.tfvars
```

# useful cli 
```
aws ecs update-service --cluster nodejs-app-cluster --service nodejs-app-service-2353fb1e --force-new-deployment
```
# if it works, then git push
```
$ git checkout dev
$ git add .
$ git commit -m "changes"
$ git push origin -u dev
