terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 5.0"
        }
        docker = { 
            source = "kreuzwerker/docker" 
            version = "3.0.2" 
        } 
    }
}

provider "aws" {
    region = "us-east-1"
    shared_credentials_files = ["./credentials"]
    default_tags {
        tags = {
            Course       = "CSSE6400"
            Name         = "TaskOverflow"
            Automation   = "Terraform"
        }
    }
}

data "aws_ecr_authorization_token" "ecr_token" {}

provider "docker" { 
 registry_auth { 
   address = data.aws_ecr_authorization_token.ecr_token.proxy_endpoint 
   username = data.aws_ecr_authorization_token.ecr_token.user_name 
   password = data.aws_ecr_authorization_token.ecr_token.password 
 } 
}

resource "aws_ecr_repository" "taskoverflow" { 
 name = "taskoverflow" 
}

resource "docker_image" "taskoverflow" {
  name = "${aws_ecr_repository.taskoverflow.repository_url}:latest"
  build {
    context  = "."  # Current directory
    platform = "linux/amd64"  # Optional, ensures compatibility with ECS
  }
}
 
resource "docker_registry_image" "taskoverflow" { 
 name = docker_image.taskoverflow.name
}

resource "docker_image" "worker" {
  name = "${aws_ecr_repository.taskoverflow.repository_url}:worker"
  build {
    context  = "."  # Current directory
    dockerfile = "Dockerfile.worker"  # Use the new Dockerfile for the worker
    platform = "linux/amd64"  # Optional, ensures compatibility with ECS
  }
}

resource "docker_registry_image" "worker" { 
  name = docker_image.worker.name
}
