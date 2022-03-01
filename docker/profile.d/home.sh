# It is impossible to remove an environment variable from Docker image manifest
# after it's been added there with `ENV`. The original AWX image has it added.
# VS Code uses the manifest to populate `/etc/environment` on devcontainer
# (re-)build. That file is read on `su` command and breaks the root user's
# environment. This hack attempts to mitigate this issue.
sudo sed -i '/HOME=/d' /etc/environment
