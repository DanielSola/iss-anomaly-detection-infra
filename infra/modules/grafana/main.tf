resource "aws_instance" "grafana" {
  ami           = "ami-0bbd3f89449af0b30"
  instance_type = "t4g.nano"
  key_name      = "manual"

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y software-properties-common
              wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
              echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
              sudo apt-get update
              sudo apt-get install -y grafana
              # Inject SMTP config
              sudo tee -a /etc/grafana/grafana.ini > /dev/null << EOT
              [smtp]
              enabled = true
              host = smtp.gmail.com:587
              user = "${var.notification_sender_email}"
              password = "${var.notification_sender_app_password}"
              from_address = "${var.notification_sender_email}"
              from_name = ISS Anomaly Detector
              skip_verify = false
              EOT
              sudo systemctl start grafana-server
              sudo systemctl enable grafana-server
            EOF

  vpc_security_group_ids = [aws_security_group.grafana_sg.id]


  iam_instance_profile = aws_iam_instance_profile.grafana_profile.name # Reference the IAM instance profile
  tags = {
    Name = "Grafana-EC2"
  }
}

resource "aws_security_group" "grafana_sg" {
  name        = "grafana-sg"
  description = "Allow Grafana traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow access from any IP (change to a specific IP if required)
  }

  # Allow SSH access (port 22) from specific IP for remote access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Open to all IPs (for testing; restrict it in production)
  }

  # Allow outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_vpc" "default" {
  default = true
}
