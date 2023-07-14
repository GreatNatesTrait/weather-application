# # Stage 1: Build the Angular app
# FROM node:14 as build-stage
# WORKDIR /app

# # Copy the Angular app source code
# COPY weather-app/ClientApp/package*.json ./
# RUN npm ci

# COPY weather-app/ClientApp/ .
# RUN ng build --configuration production --aot

# # Stage 2: Build the .NET app
# FROM mcr.microsoft.com/dotnet/sdk:6.0 AS publish-stage
# WORKDIR /src
# COPY . .

# # Publish the .NET app
# RUN dotnet publish -c Release -o /app/publish

# # Stage 3: Create the final image
# FROM mcr.microsoft.com/dotnet/aspnet:6.0
# WORKDIR /app
# COPY --from=publish-stage /app/publish .

# # Set the ASP.NET environment variables if needed
# # ENV ASPNETCORE_ENVIRONMENT=Production

# # Expose the port used by the ASP.NET app
# EXPOSE 80

# # Start the ASP.NET app
# ENTRYPOINT ["dotnet", "weather-app.dll"]





# Stage 1: Build Angular app
FROM node:18 AS angular
WORKDIR /app

# Copy the client app source code
COPY weather-app/ClientApp ./

# Install dependencies and build the Angular app
RUN npm install
RUN npm run build

# Stage 2: Build and publish ASP.NET app
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS dotnet
WORKDIR /app

# Copy the ASP.NET app source code
COPY weather-app ./

# Copy the built Angular app from the previous stage
COPY --from=angular /app/dist ./ClientApp/dist

# Restore and build the ASP.NET app
RUN dotnet restore
RUN dotnet publish -c Release -o ./publish

# Stage 3: Final image with the published app
FROM mcr.microsoft.com/dotnet/aspnet:6.0
WORKDIR /app

# Copy the published app from the previous stage
COPY --from=dotnet /app/publish .

# Expose the required port (change if necessary)
EXPOSE 80

# Set the entry point for the container
ENTRYPOINT ["dotnet", "weather-app.dll"]

