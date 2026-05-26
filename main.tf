module "nlb" {
  source = "git::https://github.com/PlatformStackPulse/tf-atom-lb-aws.git?ref=v1.1.0"

  enabled   = module.this.enabled
  namespace = var.namespace
  name      = var.name
  stage     = var.stage
  tags      = var.tags

  internal           = true
  load_balancer_type = "network"
  subnet_ids         = var.subnet_ids
}

module "target_group" {
  source = "git::https://github.com/PlatformStackPulse/tf-atom-lb-target-group-aws.git?ref=v1.1.0"

  enabled   = module.this.enabled
  namespace = var.namespace
  name      = "${var.name}-tg"
  stage     = var.stage
  tags      = var.tags

  port        = var.target_port
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = var.target_type

  health_check_protocol = "TCP"
  health_check_port     = tostring(var.target_port)
  health_check_path     = null
  health_check_matcher  = null
}

module "tcp_listener" {
  source = "git::https://github.com/PlatformStackPulse/tf-atom-lb-listener-aws.git?ref=v1.1.0"

  enabled   = module.this.enabled
  namespace = var.namespace
  name      = "${var.name}-tcp"
  stage     = var.stage
  tags      = var.tags

  load_balancer_arn = module.nlb.arn
  port              = var.listener_port
  protocol          = "TCP"
  target_group_arn  = module.target_group.arn
}
