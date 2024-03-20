data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "this" {
  #checkov:skip=CKV2_AWS_12:Solace is not opinionated on the format of the VPC's default security group
  #checkov:skip=CKV2_AWS_11:Solace is not opinionated on the use of VPC flow logging

  count = var.create_network ? 1 : 0

  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name                                        = var.cluster_name
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  lifecycle {
    precondition {
      condition     = can(cidrhost(var.vpc_cidr, 0))
      error_message = "A valid IPv4 CIDR must be provided for 'vpc_cidr' variable."
    }
  }
}

resource "aws_vpc_ipv4_cidr_block_association" "secondary" {
  count = var.create_network ? length(var.vpc_secondary_cidrs) : 0

  vpc_id     = aws_vpc.this[0].id
  cidr_block = var.vpc_secondary_cidrs[count.index]
}

resource "aws_internet_gateway" "gateway" {
  count = var.create_network ? 1 : 0

  vpc_id = aws_vpc.this[0].id

  tags = {
    Name = var.cluster_name
  }
}

### public subnets

resource "aws_subnet" "public" {
  count             = var.create_network ? 3 : 0
  vpc_id            = aws_vpc.this[0].id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name                     = "${var.cluster_name}-public-${count.index}"
    "kubernetes.io/role/elb" = var.pod_spread_policy == "full" || count.index < 2 ? "1" : "0"
  }

  lifecycle {
    precondition {
      condition     = length(var.public_subnet_cidrs) == 3
      error_message = "Three valid IPv4 CIDRs must be provided in the 'public_subnet_cidrs' variable."
    }
  }

  depends_on = [aws_vpc_ipv4_cidr_block_association.secondary]
}

resource "aws_eip" "nat" {
  #checkov:skip=CKV2_AWS_19:False positive - the EIPs are assoicated with the NAT Gateways below
  count = var.create_network ? 3 : 0
}

resource "aws_nat_gateway" "nat" {
  count = var.create_network ? 3 : 0

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    "Name" = "${var.cluster_name}-public-${count.index}"
  }
}

resource "aws_route_table" "public" {
  count = var.create_network ? 1 : 0

  vpc_id = aws_vpc.this[0].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway[0].id
  }

  tags = {
    Name = "${var.cluster_name}-public"
  }
}

resource "aws_route_table_association" "public" {
  count = var.create_network ? length(aws_subnet.public) : 0

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
}

### private subnets

resource "aws_subnet" "private" {
  count             = var.create_network ? 3 : 0
  vpc_id            = aws_vpc.this[0].id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name                              = "${var.cluster_name}-private-${count.index}"
    "kubernetes.io/role/internal-elb" = var.pod_spread_policy == "full" || count.index < 2 ? "1" : "0"
  }

  lifecycle {
    precondition {
      condition     = length(var.private_subnet_cidrs) == 3
      error_message = "Three valid IPv4 CIDRs must be provided in the 'private_subnet_cidrs' variable."
    }
  }

  depends_on = [aws_vpc_ipv4_cidr_block_association.secondary]
}

resource "aws_route_table" "private" {
  count  = var.create_network ? length(aws_subnet.public) : 0
  vpc_id = aws_vpc.this[0].id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[count.index].id
  }

  tags = {
    Name = "${var.cluster_name}-private-${count.index}"
  }
}

resource "aws_route_table_association" "private" {
  count = var.create_network ? length(aws_subnet.private) : 0

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_nat_gateway" "private_nat" {
  count = var.create_network ? length(aws_subnet.private) : 0

  connectivity_type = "private"
  subnet_id         = aws_subnet.private[count.index].id

  tags = {
    "Name" = "${var.cluster_name}-private-${count.index}"
  }
}

### cluster subnets (optional)

resource "aws_subnet" "cluster" {
  count = var.create_network && var.create_cluster_subnets ? 3 : 0

  vpc_id            = aws_vpc.this[0].id
  cidr_block        = var.cluster_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.cluster_name}-cluster-${count.index}"
  }

  lifecycle {
    precondition {
      condition     = length(var.cluster_subnet_cidrs) == 3
      error_message = "Three valid IPv4 CIDRs must be provided in the 'cluster_subnet_cidrs' variable."
    }
  }

  depends_on = [aws_vpc_ipv4_cidr_block_association.secondary]
}

resource "aws_route_table" "cluster" {
  count  = var.create_network ? length(aws_subnet.cluster) : 0
  vpc_id = aws_vpc.this[0].id

  tags = {
    Name = "${var.cluster_name}-cluster-${count.index}"
  }
}

resource "aws_route" "cluster_nat" {
  count = var.create_network ? length(aws_route_table.cluster) : 0

  route_table_id         = aws_route_table.cluster[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[count.index].id
}

resource "aws_route" "cluster_private_nat" {
  count = var.create_network ? length(aws_route_table.cluster) : 0

  route_table_id         = aws_route_table.cluster[count.index].id
  destination_cidr_block = "10.0.0.0/8"
  nat_gateway_id         = aws_nat_gateway.private_nat[count.index].id
}

resource "aws_route_table_association" "cluster" {
  count = var.create_network ? length(aws_subnet.cluster) : 0

  subnet_id      = aws_subnet.cluster[count.index].id
  route_table_id = aws_route_table.cluster[count.index].id
}