Relatively simple docker-compose configuration to hide Ollama and Open-WebUI
behind self-signed reversed proxy.

After cloning, run the following in a bash terminal from the root of the
repository:
```bash
./nginx/create_certs.bash
./run.bash
```

# Restricted Network Usage
Part of the core intent of this setup is to run the service stack such that
they may communicate with each other freely, with their exposed

## Managing Ollama Models
**Quickstart**:
```bash
./cli.bash
# Then within the container cli:
ollama model list
ollama pull llama3:8b
```

With the internet essentially "cut off" from the core Ollama service, we need
a way to manage models for this stack to be able to do anything.
The `cli.bash` script runs a docker container instance of the Ollama docker
image and drops you into a bash shell to perform various `ollama` commands as
necessary to pull models.
This container is hooked up to the same docker volume as the network-restricted
Ollama instance, so models pulled or removed here will be observable from the
network-restricted container as well.
Local tests of pulling and removing models in this manner have been shown,
however it is currently unknown to me if there are any outstanding
race-conditions subject to this use-case.

## Iptables backup
This is a record of how to make use of `iptables` on the host if don't want to
specifically disable IP masquerading.

**Quickstart**:
```bash
# Allow local communication within the network
sudo iptables -A FORWARD -s 172.128.0.0/16 -d 172.128.0.0/16 -j ACCEPT

# Allow communication to localhost
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A OUTPUT -o lo -j ACCEPT

# Block all other outbound traffic from the custom network
sudo iptables -A FORWARD -s 172.128.0.0/16 ! -d 172.128.0.0/16 -j DROP
```

If you want to be able to restrict your Ollama "stack" from being able to reach
out to the internet, putting a hard stop in these tools from being able to
exfiltrate data, but still allow interaction over the exposed ports with
the local host, we have to set up rules within `iptables` on your host machine.
This will require knowing the subnet CIDR block of the docker `bridge` network
created and utilized in this setup.
Normally, when Docker creates a `bridge` network, it will automatically assign
a subnet.
We explicitly configure via the `docker-compose.yaml` file a specific CIDR
block for the docker network created that should be assigned so that this
becomes deterministic instead.
The `ollama`, `open-webui` and `reverse-proxy` services are a part of this
`restricted_internal` network.

# Setting CGroupFS Driver
[Trouble shooting page from NVIDIA](
https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/troubleshooting.html#containers-losing-access-to-gpus-with-error-failed-to-initialize-nvml-unknown-error).

You might encounter that after running the ollama container for a while it
seems like your GPUs have "disconnected":
  * Attempting to run `nvidia-smi` from within the container fails, responding
    with "Failed to initialize NVML: Unknown Error".
  * New Ollama model instantiations proceed to use the CPU instead of any GPUs
    causing very slow processing performance.

Example `/etc/docker/deamon.json` file with this change:
```json
{
    "runtimes": {
        "nvidia": {
            "path": "nvidia-container-runtime",
            "runtimeArgs": []
        }
    },
    "exec-opts": ["native.cgroupdriver=cgroupfs"]
}
```
