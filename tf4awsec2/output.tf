output "alb_dns_name" {
  value = aws_lb.my_alb.dns_name
}

output "vpc_id" {
  value = aws_vpc.RAG_vpc.id
}

output "aws_launch_template_id" {
  value = aws_launch_template.my_template.id
}