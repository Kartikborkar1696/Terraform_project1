provider "aws" {
    region = "us-east-1"
    version = "~> 2.46"
  
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraformstatefiletesting59"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name = "terraformlock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_default_vpc" "default" {

  
}

resource "aws_security_group" "mysg23" {
    name = "mysg23"
    vpc_id = aws_default_vpc.default.id

    ingress {
      cidr_blocks = [ "0.0.0.0/0" ]
      from_port = 80
      to_port = 80
      protocol = "tcp"
    }

    ingress {
      cidr_blocks = [ "0.0.0.0/0" ]
      from_port = 22
      to_port = 22
      protocol = "tcp"
    }

    egress {
      cidr_blocks = [ "0.0.0.0/0" ]
      from_port = 0
      to_port = 0
      protocol = -1
    }

  
}

resource "aws_instance" "myserver" {
    ami = data.aws_ami.aws_linux_2_latest.id
    key_name = "terraform05may2022"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.mysg23.id]
    subnet_id = tolist(data.aws_subnet_ids.default_subnets.ids)[0]


    connection {
      type = "ssh"
      host = self.public_ip
      user = "ec2-user"
      private_key = file(var.aws_key_pair)
    }

    provisioner "remote-exec" {
        inline = [
            "sudo yum install httpd -y",
            "sudo service httpd start",
            "echo This is Welcome Page|sudo tee /var/www/html/index.html"
        ]
    
    }
  
}

terraform {
  backend "s3" {
    bucket = "terraformstatefiletesting59"
    key = "global/s3/terraform.tfstate"
    region = "us-east-1"

    dynamodb_table = "terraformlock"
    encrypt = true
  }
}