resource "aws_security_group" "web_sg" {
  name        = "devops-web-sg"
  description = "App server: SSH + HTTP + app port"
  vpc_id      = aws_vpc.main.id
  tags        = { Name = "devops-app-security-group" }
}

resource "aws_security_group" "monitoring_sg" {
  name        = "devops-monitoring-sg"
  description = "Monitoring server: SSH + Grafana public UI + Loki ingest"
  vpc_id      = aws_vpc.main.id
  tags        = { Name = "devops-monitoring-security-group" }
}

resource "aws_security_group" "jenkins_sg" {
  name        = "devops-jenkins-sg"
  description = "Jenkins controller: SSH + web UI + inbound agent port"
  vpc_id      = aws_vpc.main.id
  tags        = { Name = "devops-jenkins-security-group" }
}

resource "aws_security_group" "jenkins_agent_sg" {
  name        = "devops-jenkins-agent-sg"
  description = "Jenkins build agent: SSH only, from the controller and admin CIDR"
  vpc_id      = aws_vpc.main.id
  tags        = { Name = "devops-jenkins-agent-security-group" }
}

# Egress

resource "aws_security_group_rule" "web_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web_sg.id
}

resource "aws_security_group_rule" "monitoring_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.monitoring_sg.id
}

resource "aws_security_group_rule" "jenkins_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.jenkins_sg.id
}

resource "aws_security_group_rule" "jenkins_agent_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.jenkins_agent_sg.id
}

# ---------------------------------------------------------------------------
# web_sg (app_server)
# ---------------------------------------------------------------------------

resource "aws_security_group_rule" "web_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.ssh_allowed_cidr]
  security_group_id = aws_security_group.web_sg.id
}

resource "aws_security_group_rule" "web_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web_sg.id
}

resource "aws_security_group_rule" "web_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web_sg.id
}

resource "aws_security_group_rule" "web_app_port" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web_sg.id
}

resource "aws_security_group_rule" "prometheus_to_web" {
  type                     = "ingress"
  from_port                = 9100
  to_port                  = 9100
  protocol                 = "tcp"
  security_group_id        = aws_security_group.web_sg.id
  source_security_group_id = aws_security_group.monitoring_sg.id
}

# ---------------------------------------------------------------------------
# monitoring_sg
# ---------------------------------------------------------------------------

resource "aws_security_group_rule" "monitoring_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.ssh_allowed_cidr]
  security_group_id = aws_security_group.monitoring_sg.id
}

resource "aws_security_group_rule" "monitoring_grafana" {
  type              = "ingress"
  from_port         = 3000
  to_port           = 3000
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.monitoring_sg.id
}

resource "aws_security_group_rule" "monitoring_alertmanager" {
  type              = "ingress"
  from_port         = 9093
  to_port           = 9093
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.monitoring_sg.id
}

resource "aws_security_group_rule" "loki_from_app" {
  type                     = "ingress"
  from_port                = 3100
  to_port                  = 3100
  protocol                 = "tcp"
  security_group_id        = aws_security_group.monitoring_sg.id
  source_security_group_id = aws_security_group.web_sg.id
}

resource "aws_security_group_rule" "loki_from_jenkins" {
  type                     = "ingress"
  from_port                = 3100
  to_port                  = 3100
  protocol                 = "tcp"
  security_group_id        = aws_security_group.monitoring_sg.id
  source_security_group_id = aws_security_group.jenkins_sg.id
}

resource "aws_security_group_rule" "loki_from_agent" {
  type                     = "ingress"
  from_port                = 3100
  to_port                  = 3100
  protocol                 = "tcp"
  security_group_id        = aws_security_group.monitoring_sg.id
  source_security_group_id = aws_security_group.jenkins_agent_sg.id
}

resource "aws_security_group_rule" "prometheus_to_monitoring_self" {
  type                     = "ingress"
  from_port                = 9100
  to_port                  = 9100
  protocol                 = "tcp"
  security_group_id        = aws_security_group.monitoring_sg.id
  source_security_group_id = aws_security_group.monitoring_sg.id
}

# ---------------------------------------------------------------------------
# jenkins_sg (controller)
# ---------------------------------------------------------------------------

resource "aws_security_group_rule" "jenkins_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.ssh_allowed_cidr]
  security_group_id = aws_security_group.jenkins_sg.id
}

resource "aws_security_group_rule" "jenkins_web_ui" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.jenkins_sg.id
}

resource "aws_security_group_rule" "prometheus_to_jenkins" {
  type                     = "ingress"
  from_port                = 9100
  to_port                  = 9100
  protocol                 = "tcp"
  security_group_id        = aws_security_group.jenkins_sg.id
  source_security_group_id = aws_security_group.monitoring_sg.id
}

resource "aws_security_group_rule" "agent_to_jenkins_jnlp" {
  type                     = "ingress"
  from_port                = 50000
  to_port                  = 50000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.jenkins_sg.id
  source_security_group_id = aws_security_group.jenkins_agent_sg.id
}

# ---------------------------------------------------------------------------
# jenkins_agent_sg
# ---------------------------------------------------------------------------

resource "aws_security_group_rule" "jenkins_ssh_to_agent" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.jenkins_agent_sg.id
  source_security_group_id = aws_security_group.jenkins_sg.id
}

resource "aws_security_group_rule" "agent_ssh_admin" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.ssh_allowed_cidr]
  security_group_id = aws_security_group.jenkins_agent_sg.id
}

resource "aws_security_group_rule" "prometheus_to_agent" {
  type                     = "ingress"
  from_port                = 9100
  to_port                  = 9100
  protocol                 = "tcp"
  security_group_id        = aws_security_group.jenkins_agent_sg.id
  source_security_group_id = aws_security_group.monitoring_sg.id
}
