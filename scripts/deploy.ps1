param(
    [string]$DockerUsername = $env:DOCKER_USERNAME,
    [string]$GitSha = $env:GITHUB_SHA
)

if (-not $DockerUsername) {
    Write-Error "DOCKER_USERNAME is not set."
    exit 1
}

if (-not $GitSha) {
    Write-Error "GITHUB_SHA is not set."
    exit 1
}

Write-Host "==> Stopping running containers (volumes preserved)..."
docker compose down

Write-Host "==> Pulling backend image from registry..."
docker pull "${DockerUsername}/cloudnative-backend:${GitSha}"

Write-Host "==> Pulling frontend image from registry..."
docker pull "${DockerUsername}/cloudnative-frontend:${GitSha}"

Write-Host "==> Tagging images as latest..."
docker tag "${DockerUsername}/cloudnative-backend:${GitSha}" "${DockerUsername}/cloudnative-backend:latest"
docker tag "${DockerUsername}/cloudnative-frontend:${GitSha}" "${DockerUsername}/cloudnative-frontend:latest"

Write-Host "==> Starting application stack..."
docker compose up -d

Write-Host "==> Deployment complete."
docker compose ps
