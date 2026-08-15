output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "private_subnet_id" {
  value = aws_subnet.private.id
}

output "rds_subnet_ids" {
  value = [aws_subnet.rds_a.id,
  aws_subnet.rds_b.id]

}