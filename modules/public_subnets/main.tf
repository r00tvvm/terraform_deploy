resource "aws_subnet" "pubic_subnets" {
  count = "${length(var.public_subnets)}"

  vpc_id     = "${var.vpc_id}"
  cidr_block = "${element(var.public_subnets,count.index)}"

  map_public_ip_on_launch = true

  tags {
    Name = "${var.service_name}-${count.index}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Create an AWS Internet Gateway in the specified VPC
resource "aws_internet_gateway" "gtw" {
  vpc_id = "${var.vpc_id}"

  tags = {
    Name = "${var.service_name}-gtw"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Create a route table for the Internet Gateway
resource "aws_route_table" "rtable" {
  vpc_id = "${var.vpc_id}"

  # Route all non-subnet traffic through the Internet Gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gtw.id}"
  }

  tags {
    Name = "${var.service_name}-rt"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Associate the Public Subnets to the Internet Gateway route table
resource "aws_route_table_association" "public" {
  count = "${length(var.public_subnets)}"

  subnet_id      = "${element(aws_subnet.pubic_subnets.*.id, count.index)}"
  route_table_id = "${aws_route_table.rtable.id}"

  lifecycle {
    create_before_destroy = true
  }
}

output "public_subnets_ids" {
  value = "${join(",", aws_subnet.pubic_subnets.*.id)}"
}


