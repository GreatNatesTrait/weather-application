# Stage 1: Build the Angular app
FROM node:14 as build-stage
WORKDIR /app

# Copy the Angular app source code
COPY weather-app/ClientApp/package*.json ./
RUN npm ci

COPY weather-app/ClientApp/ .
RUN npm run build

# Stage 2: Build the .NET app
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS publish-stage
WORKDIR /src
COPY . .

# Publish the .NET app
RUN dotnet publish -c Release -o /app/publish

# Stage 3: Create the final image
FROM mcr.microsoft.com/dotnet/aspnet:6.0
WORKDIR /app
COPY --from=publish-stage /app/publish .

# Set the ASP.NET environment variables if needed
# ENV ASPNETCORE_ENVIRONMENT=Production

# Expose the port used by the ASP.NET app
EXPOSE 80

# Start the ASP.NET app
ENTRYPOINT ["dotnet", "weather-app.dll"]
