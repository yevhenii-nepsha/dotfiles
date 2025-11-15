# Podman - Docker Desktop Alternative

Complete guide for using Podman as Docker Desktop replacement in dotfiles.

## What is Podman?

Podman is a daemonless container engine for developing, managing, and running OCI Containers on macOS and Linux. It's a drop-in replacement for Docker Desktop with these advantages:

- **Open-source and free** - No licensing restrictions
- **Daemonless** - No background daemon required
- **Rootless by default** - Better security
- **Docker-compatible** - Same commands and compose files
- **Lightweight** - Lower resource usage

## Installation

Podman is automatically installed via dotfiles `./install` script:

1. **Homebrew packages** (from `base.Brewfile`):
   - `podman` - Container engine
   - `podman-compose` - Docker Compose compatibility

2. **Setup script** (`scripts/setup-podman.sh`):
   - Initializes Podman machine
   - Configures auto-start via `brew services`
   - Verifies installation

3. **Shell configuration** (`config/zsh/podman.zsh`):
   - Docker aliases (`docker` → `podman`)
   - Environment variables (`DOCKER_HOST`)
   - Helper functions

## Manual Installation

If you need to set up Podman manually:

```bash
# Install Podman
brew install podman podman-compose

# Initialize and start machine
podman machine init --cpus 2 --memory 4096 --disk-size 100
podman machine start

# Configure auto-start
brew services start podman

# Verify
podman version
```

## Usage

### Basic Commands

Podman is 100% compatible with Docker commands:

```bash
# Container management (identical to Docker)
docker ps
docker run -it ubuntu bash
docker stop <container-id>
docker rm <container-id>

# Image management
docker pull nginx
docker images
docker rmi nginx

# Docker Compose
cd ~/docker-compose/media
docker-compose up -d
docker-compose logs -f
docker-compose down
```

### Podman Machine Management

Use built-in helper functions from `podman.zsh`:

```bash
# Show machine status
podman-status

# Start machine (if stopped)
podman-start

# Stop machine
podman-stop

# Restart machine
podman-restart

# Clean up unused resources
podman-cleanup
```

### Direct Podman Commands

You can also use native Podman commands:

```bash
# Machine management
podman machine list
podman machine start
podman machine stop
podman machine ssh        # SSH into machine

# Container management (same as Docker)
podman ps
podman run ...
podman exec ...
```

## Migration from Docker Desktop

### Before Migration

1. **Backup Docker data** (optional):
   ```bash
   # Export images you want to keep
   docker save image:tag -o image.tar

   # Export container data/volumes manually
   docker cp container:/path /host/path
   ```

2. **Stop Docker Desktop**:
   - Quit Docker Desktop application
   - Do NOT uninstall yet (in case you need to rollback)

### Migration Process

1. **Install dotfiles with Podman**:
   ```bash
   cd ~/.dotfiles
   git pull origin migrate-to-podman
   ./install
   ```

2. **Test Podman**:
   ```bash
   # Reload shell
   source ~/.zshrc

   # Test Docker alias
   docker version
   docker ps

   # Test Compose
   docker-compose --version
   ```

3. **Migrate Docker Compose services**:
   ```bash
   # Navigate to your compose directory
   cd ~/docker-compose/media

   # No changes needed - compose files are compatible!
   docker-compose up -d

   # Verify services
   docker ps
   docker-compose logs -f
   ```

4. **Verify everything works**:
   - Test all services
   - Check logs for errors
   - Test external access (Cloudflare tunnels, etc.)

5. **Uninstall Docker Desktop** (optional):
   ```bash
   # Only after confirming Podman works
   brew uninstall --cask docker
   ```

### Import Images (Optional)

If you saved Docker images:

```bash
# Import saved images
podman load -i image.tar

# Verify
docker images
```

## Configuration

### Podman Machine Settings

Default machine configuration (from `setup-podman.sh`):
- **CPUs**: 2
- **Memory**: 4GB
- **Disk**: 100GB
- **Mode**: Rootless

To customize:

```bash
# Remove existing machine
podman machine stop
podman machine rm

# Create with custom settings
podman machine init \
  --cpus 4 \
  --memory 8192 \
  --disk-size 200

podman machine start
```

### Environment Variables

Configured in `config/zsh/podman.zsh`:

```bash
# Docker socket compatibility
export DOCKER_HOST="unix://$HOME/.local/share/containers/podman/machine/podman-api.sock"
```

This ensures tools that look for Docker socket will work with Podman.

### Auto-start Configuration

Podman machine starts automatically on macOS login via `brew services`:

```bash
# Check auto-start status
brew services list | grep podman

# Enable auto-start
brew services start podman

# Disable auto-start
brew services stop podman
```

## Docker Compose Compatibility

### Using Docker Compose Files

Podman is fully compatible with Docker Compose:

```bash
cd ~/docker-compose/media
docker-compose up -d      # Works via alias
```

Or use Podman Compose directly:

```bash
podman-compose up -d      # Native Podman command
```

### Known Differences

Most compose files work without changes. Minor differences:

1. **host.docker.internal** - Works in Podman 4.0+
2. **Network names** - May differ slightly (use explicit names)
3. **Volume permissions** - Same as Docker on macOS

## Troubleshooting

### Podman machine won't start

```bash
# Check machine status
podman machine list

# View detailed logs
podman machine start --log-level debug

# Remove and recreate
podman machine stop
podman machine rm
podman machine init
podman machine start
```

### "Cannot connect to Podman socket"

```bash
# Ensure machine is running
podman machine start

# Check socket path
echo $DOCKER_HOST

# Verify socket exists
ls -la ~/.local/share/containers/podman/machine/
```

### Docker Compose not working

```bash
# Check podman-compose version
podman-compose --version

# Try native Podman command instead
podman-compose up -d

# Verify DOCKER_HOST is set
echo $DOCKER_HOST
```

### High resource usage

```bash
# Check current allocation
podman machine info

# Reduce resources
podman machine stop
podman machine set --cpus 2 --memory 2048
podman machine start
```

### Permission errors

Podman runs rootless by default, which is more secure but may cause permission issues:

```bash
# Check if rootless
podman info | grep rootless

# For troubleshooting, check machine
podman machine ssh
id  # Check user inside machine
```

## Performance Tips

1. **Resource allocation** - Adjust CPU/memory based on workload
2. **Volume mounts** - Use `:cached` or `:delegated` flags for better performance
3. **Cleanup regularly** - Use `podman-cleanup` to free resources
4. **Prune unused data**:
   ```bash
   docker system prune -a
   ```

## Differences from Docker Desktop

### Advantages

✅ Free and open-source
✅ Lower resource usage
✅ Better security (rootless)
✅ No background daemon
✅ Faster startup

### Limitations

⚠️ No GUI (CLI only)
⚠️ Slightly different machine management
⚠️ Some Docker Desktop features not available

### Docker Desktop Features Not Available

- Desktop GUI dashboard
- Kubernetes integration (use Minikube instead)
- Docker Extensions
- Volume browser GUI (use CLI)

## Best Practices

1. **Always use aliases** - Use `docker` commands for compatibility
2. **Regular cleanup** - Run `podman-cleanup` weekly
3. **Monitor resources** - Check `podman machine info` periodically
4. **Version control** - Keep compose files in git
5. **Environment files** - Use `.env` files, never commit secrets

## Helper Functions Reference

From `config/zsh/podman.zsh`:

| Function | Description |
|----------|-------------|
| `podman-start` | Start Podman machine if stopped |
| `podman-stop` | Stop Podman machine |
| `podman-restart` | Restart Podman machine |
| `podman-status` | Show machine status and version |
| `podman-cleanup` | Clean up containers, images, volumes |

## Additional Resources

- [Podman Documentation](https://docs.podman.io/)
- [Podman Desktop](https://podman-desktop.io/) - Optional GUI
- [Docker to Podman Migration](https://docs.podman.io/en/latest/markdown/podman-docker.1.html)
- [Podman Compose](https://github.com/containers/podman-compose)

## Rollback to Docker Desktop

If you need to rollback:

1. Stop Podman:
   ```bash
   brew services stop podman
   podman machine stop
   ```

2. Reinstall Docker Desktop:
   ```bash
   brew install --cask docker
   ```

3. Temporarily disable Podman aliases:
   ```bash
   # Comment out in ~/.zshrc
   # source "${DOTFILES_DIR}/config/zsh/podman.zsh"
   ```

4. Restart terminal and start Docker Desktop

## Support

For issues specific to this dotfiles setup:
- Check [Troubleshooting.md](Troubleshooting.md)
- Review [Docker-Services.md](Docker-Services.md) for service-specific issues
- File issues in dotfiles repository

For Podman issues:
- [Podman GitHub Issues](https://github.com/containers/podman/issues)
- [Podman Discussions](https://github.com/containers/podman/discussions)
