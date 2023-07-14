# Base image with .NET SDK, Node.js, Git, and AWS CLI
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS dotnet
WORKDIR /app

# Install Node.js
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -
RUN apt-get install -y nodejs

# Install Angular CLI
RUN npm install -g @angular/cli

# Install Git
RUN apt-get install -y git

# Install Terraform
RUN apt-get install -y unzip
RUN curl -fsSL https://releases.hashicorp.com/terraform/1.0.9/terraform_1.0.9_linux_amd64.zip -o terraform.zip
RUN unzip terraform.zip -d /usr/local/bin

# Install AWS CLI
RUN apt-get install -y python3-pip
RUN pip3 install awscli

# Expose ports for ASP.NET app and Angular app
EXPOSE 5000
EXPOSE 4200

# Set working directory for the app
WORKDIR /app/YourAspNetApp

#CMD dotnet watch run
