param (
    [string]$BACKEND_IMAGE,
    [string]$FRONTEND_IMAGE
)

Write-Host "Stopping current containers..."
docker compose down

Write-Host "Pulling latest backend image: $BACKEND_IMAGE"
docker pull $BACKEND_IMAGE

Write-Host "Pulling latest frontend image: $FRONTEND_IMAGE"
docker pull $FRONTEND_IMAGE

Write-Host "Starting application..."
docker compose up -d

Write-Host "Deployment finished. Current containers:"
docker ps
