FROM ubuntu:20.04

USER root

# Reset the environment variable baked into the awx image
ENV HOME=

##
# Configure system
##
# Install tools
RUN apt-get update && \
  apt install -y apt-transport-https && \
  apt install -y python3-pip && \
  apt install -y zsh ca-certificates curl apt-transport-https lsb-release gnupg wget git

# Install az cli
RUN curl -sL https://packages.microsoft.com/keys/microsoft.asc | \ 
    gpg --dearmor | \
    tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Install kubectl with Azure-related plugins
RUN az aks install-cli

# Instal Powerline
RUN pip3 install powerline-status powerline-gitstatus
COPY powerline/ /usr/local/lib/python3.8/site-packages/powerline/config_files/

# Configure Zsh for root user
RUN chsh -s /bin/zsh && \
  sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-/root/.oh-my-zsh/custom}/themes/powerlevel10k && \
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-/root/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
  git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-/root/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
COPY bootstrap/.p10k.zsh /root/
COPY bootstrap/.zshrc /root/

# Configure /etc/profile.d
COPY profile.d/* /etc/profile.d/

# Configure supervisor
COPY supervisord.conf /etc/
COPY supervisor.d/* /etc/supervisor.d/

RUN echo 'Defaults secure_path = "/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin"' >> /etc/sudoers

# Copy bootstrap configuration & scripts for devops user
RUN mkdir /bootstrap
COPY bootstrap/* /bootstrap/
RUN cp -R /root/.oh-my-zsh /bootstrap/

##
# Configure ENTRYPOINT and CMD
##

COPY entrypoint.sh /usr/local/share/
RUN chmod +x /usr/local/share/entrypoint.sh

# Using `tini` for zombie-process reaping
#ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/share/entrypoint.sh"]

CMD ["sleep", "infinity"]

##
# Prepare user environment
##

ARG USER=devops

# Create the user
RUN groupadd -g 1000 ${USER} && useradd -u 1000 -g 1000 ${USER}

# Allow the user to invoke passwordless sudo
# NOTE: User is able to interact with the host's Docker anyway, so security is not lowered here
RUN echo "${USER}  ALL = (ALL)  NOPASSWD: ALL" >> /etc/sudoers

# Switch to user and change directory to $HOME
USER ${USER}
WORKDIR /home/${USER}

# Preserve image version information
ARG IMAGE_VERSION=local
