variable "vpc_id" {
    description = "ID of the VPC to use"
}

variable "vpc_cidr" {
    description = "Internal IP range, allowed to ssh to instances"
}

variable "private_subnet_one" {
    description = "ID of first subnet for EC2-instances"
}
variable "private_subnet_two" {
    description = "ID of second subnet for EC2-instances"
}

variable "subnet_one" {
    description = "ID of first subnet for Load balancer"
}
variable "subnet_two" {
    description = "ID of second subnet for Load balancer"
}

variable "ssh_key" {
    description = "ID of key pair that will be granted SSH access to the servers"
}

variable "certificate_arn" {
    description = "ARN of certificate used for load balancer"
}

variable "healthcheck_location" {
    # default TCP:22 since application might not actually be running (it's new after all)
    default = "TCP:22"
    description = "Location for Load balancer to check for response to see if instances in autoscaling group are healthy"
}

variable "s3_user_access_key" {
    description = "AWS Access key to user with read and write capabilities for bucket"
}

variable "s3_user_secret_key" {
    description = "AWS Access key to user with read and write capabilities for bucket"
}

variable "instance_type" {
    description = "Which AWS instance type (e.g. t2.micro) to start up ec2-nodes on"
}  

variable "loadbalancing_min_nodes" {
    default = 2
    description = "Minimum amount of nodes in autoscaling group"
}
variable "loadbalancing_max_nodes" {
    default = 2
    description = "Maximum amount of nodes in autoscaling group"
}
variable "loadbalancing_desired_nodes" {
    default = 2
    description = "Desired amount of nodes in autoscaling group"
}

resource "aws_iam_instance_profile" "beanstalk_service" {
    name = "beanstalk-service-user"
    roles = ["${aws_iam_role.beanstalk_service.name}"]
}

resource "aws_iam_instance_profile" "beanstalk_ec2" {
    name = "beanstalk-ec2-user"
    roles = ["${aws_iam_role.beanstalk_ec2.name}"]
}

resource "aws_iam_role" "beanstalk_service" {
    name = "beanstalk-service-role"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role" "beanstalk_ec2" {
    name = "beanstalk-ec2-role"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "beanstalk_service" {
    name = "elastic-beanstalk-service"
    roles = ["${aws_iam_role.beanstalk_service.id}"]
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkService"
}

resource "aws_iam_policy_attachment" "beanstalk_service_health" {
    name = "elastic-beanstalk-service-health"
    roles = ["${aws_iam_role.beanstalk_service.id}"]
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth"
}

resource "aws_iam_policy_attachment" "beanstalk_ec2_worker" {
    name = "elastic-beanstalk-ec2-worker"
    roles = ["${aws_iam_role.beanstalk_ec2.id}"]
    policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier"
}

resource "aws_iam_policy_attachment" "beanstalk_ec2_web" {
    name = "elastic-beanstalk-ec2-web"
    roles = ["${aws_iam_role.beanstalk_ec2.id}"]
    policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

resource "aws_iam_policy_attachment" "beanstalk_ec2_container" {
    name = "elastic-beanstalk-ec2-container"
    roles = ["${aws_iam_role.beanstalk_ec2.id}"]
    policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker"
}


resource "aws_elastic_beanstalk_application" "api" {
    name = "api"
    description = "REST api"
}

resource "aws_elastic_beanstalk_environment" "api" {
    name = "api"
    application = "${aws_elastic_beanstalk_application.api.name}"
    solution_stack_name = "64bit Amazon Linux 2016.03 v2.1.6 running Java 8"
    wait_for_ready_timeout = "20m"
  
    setting {
        namespace = "aws:ec2:vpc"
        name      = "VPCId"
        value     = "${var.vpc_id}"
    }
  
    setting {
        namespace = "aws:ec2:vpc"
        name      = "Subnets"
        value     = "${var.private_subnet_one},${var.private_subnet_two}"
    }
  
    setting {
        namespace = "aws:ec2:vpc"
        name      = "ELBSubnets"
        value     = "${var.subnet_one},${var.subnet_two}"
    } 
  
    setting {
        namespace = "aws:autoscaling:launchconfiguration"
        name      = "InstanceType"
        value     = "${var.instance_type}"
    } 
  
    setting {
        namespace = "aws:autoscaling:launchconfiguration"
        name      = "SSHSourceRestriction"
        value     = "tcp, 22, 22, ${var.vpc_cidr}"
    } 
  
    setting {
        namespace = "aws:autoscaling:asg"
        name      = "MaxSize"
        value     = "${var.loadbalancing_max_nodes}"
    } 
  
    setting {
        namespace = "aws:autoscaling:asg"
        name      = "MinSize"
        value     = "${var.loadbalancing_min_nodes}"
    } 
  
    setting {
        # Allows 600 seconds between each autoscaling action
        namespace = "aws:autoscaling:asg"
        name      = "Cooldown"
        value     = "600"
    } 
  
    setting {
        namespace = "aws:elasticbeanstalk:application"
        name      = "Application Healthcheck URL"
        value     = "${var.healthcheck_location}"
    }
  
    setting {
        # High threshold for taking down servers for debugging purposes
        namespace = "aws:elb:healthcheck"
        name      = "Interval"
        value     = "300"
    }
  
    setting {
        # High threshold for taking down servers for debugging purposes
        namespace = "aws:elb:healthcheck"
        name      = "UnhealthyThreshold"
        value     = "10"
    }
  
    setting {
        namespace = "aws:autoscaling:launchconfiguration"
        name      = "EC2KeyName"
        value     = "${var.ssh_key}"
    }
  
    setting {
        namespace = "aws:elb:loadbalancer"
        name      = "CrossZone"
        value     = "true"
    }
  
    setting {
        namespace = "aws:elb:listener:443"
        name      = "ListenerProtocol"
        value     = "HTTPS"
    }
  
    setting {
        namespace = "aws:elb:listener:443"
        name      = "InstancePort"
        value     = "80"
    }
  
    setting {
        namespace = "aws:elb:listener:443"
        name      = "SSLCertificateId"
        value     = "${var.certificate_arn}"
    }
  
    setting {
        namespace = "aws:elb:policies"
        name      = "ConnectionDrainingEnabled"
        value     = "true"
    }
  
    setting {
        namespace = "aws:elb:policies"
        name      = "ConnectionDrainingTimeout"
        value     = "20"
    }

    setting {
        namespace = "aws:elasticbeanstalk:environment"
        name      = "ServiceRole"
        value     = "${aws_iam_instance_profile.beanstalk_service.name}"
    }

    setting {
        namespace = "aws:autoscaling:launchconfiguration"
        name      = "IamInstanceProfile"
        value     = "${aws_iam_instance_profile.beanstalk_ec2.name}"
    }

}

output "api_cname" {
    value = "${aws_elastic_beanstalk_environment.api.cname}" 
}