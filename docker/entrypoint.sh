#!/usr/bin/bash
# Always start supervisor
sudo /usr/local/bin/supervisord -c /etc/supervisord.conf

if [ ! -f ~/.zshrc ] && [ ! -f ~/.p10k.zsh ]; then
  cp -R /bootstrap/.oh-my-zsh ~/
  cp /bootstrap/.zshrc ~/
  cp /bootstrap/.p10k.zsh ~/
  cat ~/.bash_history | python3 /bootstrap/bash-to-zsh-hist.py >> ~/.zsh_history
  sudo chsh -s /bin/zsh $USER
fi

# Run a command if passed
if [ $# -gt 0 ];then
    exec "$@"
fi
