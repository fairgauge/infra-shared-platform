# Data sources
data "aws_region" "current" {}

locals {
  # Calculate subnet count based on availability zones
  az_count = length(var.availability_zones)
  
  # Create subnet CIDR blocks
  public_subnets = [
    for i in range(local.az_count) : 
    cidrsubnet(var.vpc_cidr, 8, i + 1)
  ]
  
  private_subnets = [
    for i in range(local.az_count) : 
    cidrsubnet(var.vpc_cidr, 8, i + 10)
  ]
  
  database_subnets = [
    for i in range(local.az_count) : 
    cidrsubnet(var.vpc_cidr, 8, i + 20)
  ]
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = merge(var.tags, {
    Name = "${var.project_name}-shared-vpc"
  })
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  
  tags = merge(var.tags, {
    Name = "${var.project_name}-shared-igw"
  })
}

# Public Subnets
resource "aws_subnet" "public" {
  count = local.az_count
  
  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.public_subnets[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  
  tags = merge(var.tags, {
    Name = "${var.project_name}-shared-public-${var.availability_zones[count.index]}"
    Type = "public"
  })
}

# Private Subnets
resource "aws_subnet" "private" {
  count = local.az_count
  
  vpc_id            = aws_vpc.main.id
  cidr_block        = local.private_subnets[count.index]
  availability_zone = var.availability_zones[count.index]
  
  tags = merge(var.tags, {
    Name = "${var.project_name}-shared-private-${var.availability_zones[count.index]}"
    Type = "private"
  })
}

# Database Subnets
resource "aws_subnet" "database" {
  count = local.az_count
  
  vpc_id            = aws_vpc.main.id
  cidr_block        = local.database_subnets[count.index]
  availability_zone = var.availability_zones[count.index]
  
  tags = merge(var.tags, {
    Name = "${var.project_name}-shared-database-${var.availability_zones[count.index]}"
    Type = "database"
  })
}

# Database Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-shared-db-subnet-group"
  subnet_ids = aws_subnet.database[*].id
  
  tags = merge(var.tags, {
    Name = "${var.project_name}-shared-db-subnet-group"
  })
}

# Elastic IPs for NAT Gateways (cost optimization: only create what we need)
resource "aws_eip" "nat" {
  count = var.nat_gateway_count
  
  domain = "vpc"
  
  tags = merge(var.tags, {
    Name = "${var.project_name}-shared-nat-eip-${count.index + 1}"
  })
  
  depends_on = [aws_internet_gateway.main]
}

# NAT Gateways (cost-optimized: configurable count)
resource "aws_nat_gateway" "main" {
  count = var.nat_gateway_count
  
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  
  tags = merge(var.tags, {
    Name = "${var.project_name}-shared-nat-${count.index + 1}"
  })
  
  depends_on = [aws_internet_gateway.main]
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  
  tags = merge(var.tags, {
    Name = "${var.project_name}-shared-public-rt"
  })
}

# Public Route Table Associations
resource "aws_route_table_association" "public" {
  count = local.az_count
  
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private Route Tables (one per NAT Gateway for cost optimization)
resource "aws_route_table" "private" {
  count = var.nat_gateway_count > 0 ? var.nat_gateway_count : 1
  
  vpc_id = aws_vpc.main.id
  
  # Only add NAT Gateway route if NAT Gateways exist
  dynamic "route" {
    for_each = var.nat_gateway_count > 0 ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.main[count.index % var.nat_gateway_count].id
    }
  }
  
  tags = merge(var.tags, {
    Name = "${var.project_name}-shared-private-rt-${count.index + 1}"
  })
}

# Private Route Table Associations
resource "aws_route_table_association" "private" {
  count = local.az_count
  
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index % max(var.nat_gateway_count, 1)].id
}

# Database Route Table
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id
  
  tags = merge(var.tags, {
    Name = "${var.project_name}-shared-database-rt"
  })
}

# Database Route Table Associations
resource "aws_route_table_association" "database" {
  count = local.az_count
  
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}

# Security Groups

# Default Security Group (restrict default to nothing)
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id
  
  # Remove all default rules
  ingress = []
  egress  = []
  
  tags = merge(var.tags, {
    Name = "${var.project_name}-shared-default-sg"
  })
}

# Web Security Group
resource "aws_security_group" "web" {
  name_prefix = "${var.project_name}-shared-web-"
  vpc_id      = aws_vpc.main.id
  description = "Security group for web servers"
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP"
  }
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS"
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }
  
  tags = merge(var.tags, {
    Name = "${var.project_name}-shared-web-sg"
  })
}

# Database Security Group
resource "aws_security_group" "database" {
  name_prefix = "${var.project_name}-shared-database-"
  vpc_id      = aws_vpc.main.id
  description = "Security group for databases"
  
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
    description     = "MySQL/Aurora from web servers"
  }
  
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
    description     = "PostgreSQL from web servers"
  }
  
  tags = merge(var.tags, {
    Name = "${var.project_name}-shared-database-sg"
  })
}