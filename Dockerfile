
FROM ubuntu:20.04
ARG USER=${USER:-test_user}
RUN apt-get update && apt-get upgrade -y

RUN apt-get install iproute2 -y
RUN apt-get install build-essential -y
RUN apt-get install libssl-dev -y
RUN apt-get install git -y
RUN apt-get install curl -y
RUN apt-get install file -y
RUN apt-get install sudo -y
RUN apt-get install wget -y
RUN apt-get install vim -y
RUN apt-get install neovim -y


RUN useradd -ms /bin/bash $USER
RUN usermod -aG sudo $USER

RUN echo "$USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER $USER

WORKDIR /home/$USER

RUN sudo apt-get install zsh -y
RUN sudo chsh -s /bin/zsh $USER

RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.1/zsh-in-docker.sh)" -t agnoster
COPY ./ ./.dotfiles
RUN mkdir -p ~/.config/nvim
RUN sudo chmod +x ~/.dotfiles/run.sh && ~/.dotfiles/run.sh
