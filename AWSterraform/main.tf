provider "aws" {
    region = "us-west-2"
  
}

resource "aws_default_vpc" "mydefvpc" {
  
}

resource "aws_security_group" "mysg" {
    name = "kartiksg1"
    vpc_id = aws_default_vpc.mydefvpc.id   #attribute refernce

    ingress {
        from_port = 80  #argument refernce
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
  
}

resource "aws_instance" "myinstance" {
    ami = data.aws_ami.aws_linux_2_latest.id
    key_name = "terraform05may2022"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.mysg.id]
    subnet_id = tolist(data.aws_subnet_ids.default_subnets.ids)[0] 
    
    connection {
        type = "ssh"
        host = self.public_ip
        user = "ec2-user"
        private_key = file(var.aws_key_pair) #file("C:/Users/Hp/Downloads/terraform05may2022.pem")
    }

    provisioner "remote-exec" {
        inline = [
            "sudo yum install httpd -y",
            "sudo service httpd start",
            "echo hi this is Kartik and he is learning aws|sudo tee /var/www/html/index.html"
        ]
      
    }
  
}