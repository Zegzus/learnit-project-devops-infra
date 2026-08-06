moved {
  from = aws_instance.app_server
  to   = aws_instance.server["app"]
}

moved {
  from = aws_instance.monitoring_server
  to   = aws_instance.server["monitoring"]
}

moved {
  from = aws_instance.jenkins_server
  to   = aws_instance.server["jenkins"]
}

moved {
  from = aws_instance.jenkins_agent
  to   = aws_instance.server["jenkins_agent"]
}
