
MONGO_URI = "mongodb+srv://user:1234@tasks.hqybvw0.mongodb.net/?retryWrites=true&w=majority&appName=tasks"

# UPDATE BELOW 3 TOGETHER
vpc_id = "vpc-01366ef295e998680"
 # Public subnets from VPC repo
alb_subnet_ids = [ "subnet-0b677cac9e86bb88c", "subnet-05a3c73c8ff093a04" ]
 # Private subnets from VPC repo
private_subnet_ids = ["subnet-0a7eaa59d18df4749", "subnet-03aabd4ba12b5a47c"]