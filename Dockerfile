# Stage 1: Build Angular app
FROM node:18 AS angular
WORKDIR /app

# Copy the client app source code
COPY weather-app/ClientApp ./

# Install dependencies and build the Angular app
RUN npm install
RUN npm run build

# Stage 2: Build and publish ASP.NET app
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build

# Install Node.js
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash -
RUN apt-get install -y nodejs

WORKDIR /app

# Copy the ASP.NET app source code
COPY weather-app ./

# Copy the built Angular app from the previous stage
COPY --from=angular /app/dist ./ClientApp/dist

# Restore and build the ASP.NET app
RUN dotnet restore
RUN dotnet publish -c Release -o ./publish

# Stage 3: Final image with the published app
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS final
WORKDIR /app

# Copy the published app from the previous stage
COPY --from=build /app/publish .

# Expose the required port (change if necessary)
EXPOSE 80

# Set the entry point for the container
ENTRYPOINT ["dotnet", "weather-app.dll"]
