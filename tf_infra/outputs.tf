output "public_ip" {
  value       = aws_instance.webserver.public_ip
  description = "Public IP of the EC2 instance"
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.vpc.id
}

output "subnet_ids" {
  description = "List of subnet IDs"
  value       = values(aws_subnet.public_subnets)[*].id
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.demo_sg.id
}

output "private_key_path" {
  description = "Path to the private key file"
  value       = local_file.private_key.filename
  sensitive   = true
}


/*
      - name: Install SonarScanner
        run: |
          curl -sSLo sonar-scanner.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip
          unzip sonar-scanner.zip -d $HOME
          echo "$HOME/sonar-scanner-5.0.1.3006-linux/bin" >> $GITHUB_PATH
  
      - name: Run SonarQube Analysis
        env:
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
        run: |
          sonar-scanner \
            -Dsonar.projectKey=php-app \
            -Dsonar.sources=. \
            -Dsonar.host.url=http://ec2-18-170-212-19.eu-west-2.compute.amazonaws.com:9000 \
            -Dsonar.login=$SONAR_TOKEN
  
      - name: Wait for Quality Gate
        uses: sonarsource/sonarqube-quality-gate-action@master
        timeout-minutes: 5
        with:
          sonar-token: ${{ secrets.SONAR_TOKEN }}

*/