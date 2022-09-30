# Homebrew on MacOS

> updated by huwany@outlook.com Dec 29, 2020

## Arm m1 silicon

* Set up env

  ```bash
  export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.ustc.edu.cn/brew.git"
  export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.ustc.edu.cn/homebrew-core.git"
  export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles"
  
  /bin/bash -c "$(curl -fsSL https://github.com/Homebrew/install/raw/HEAD/install.sh)"
  
  or
  /bin/bash -c "$(curl -fsSL https://cdn.jsdelivr.net/gh/Homebrew/install@HEAD/install.sh)"
  
  brew tap --custom-remote --force-auto-update homebrew/cask https://mirrors.ustc.edu.cn/homebrew-cask.git
  brew tap --custom-remote --force-auto-update homebrew/cask-versions https://mirrors.ustc.edu.cn/homebrew-cask-versions.git
  brew tap --custom-remote --force-auto-update homebrew/homebrew-cask-fonts https://mirrors.aliyun.com/homebrew/homebrew-cask-fonts.git
  ```

## old ways

* set up env, *Don't forget to update the  $PATH line on .zshrc or .bashrc*

  ```bash
  export PATH="/opt/homebrew/bin:$PATH"
  #export MIRROR="https://mirrors.aliyun.com/homebrew"
  export MIRROR="https://mirrors.ustc.edu.cn"
  ```

* Get source code

  ```bash
  cd ~/Downloads 
  
  git clone ${MIRROR}/brew.git
  sudo rsync -avr ~/Downloads/brew/ /opt/homebrew/
  sudo mkdir -p "$(brew --repo)"/homebrew
  
  git clone ${MIRROR}/homebrew-core.git
  sudo rsync --delete -avr ~/Downloads/homebrew-core/ "$(brew --repo)"/Library/Taps/homebrew/homebrew-core/
  
  git clone ${MIRROR}/homebrew-cask.git
  sudo rsync --delete -avr ~/Downloads/homebrew-cask/ "$(brew --repo)"/Library/Taps/homebrew/homebrew-cask/
  
  git clone ${MIRROR}/homebrew-cask-versions.git
  sudo rsync --delete -avr ~/Downloads/homebrew-cask-versions/ "$(brew --repo)"/Library/Taps/homebrew/homebrew-cask-versions/
  
  git clone ${MIRROR}/homebrew-cask-fonts.git
  sudo rsync --delete -avr ~/Downloads/homebrew-cask-fonts/ "$(brew --repo)"/Library/Taps/homebrew/homebrew-cask-fonts/
  ```

* Replace repo

  ```bash
  cd "$(brew --repo)"
  git remote set-url origin ${MIRROR}/brew.git
  
  cd "$(brew --repo)"/Library/Taps/homebrew/homebrew-core
  git remote set-url origin ${MIRROR}/homebrew-core.git
  
  cd "$(brew --repo)"/Library/Taps/homebrew/homebrew-cask
  git remote set-url origin ${MIRROR}/homebrew-cask.git
  
  cd "$(brew --repo)"/Library/Taps/homebrew/homebrew-cask-versions
  git remote set-url origin ${MIRROR}/homebrew-cask-versions.git
  
  cd "$(brew --repo)"/Library/Taps/homebrew/homebrew-cask-fonts
  git remote set-url origin https://mirrors.aliyun.com/homebrew/homebrew-cask-fonts.git
  
  export HOMEBREW_BOTTLE_DOMAIN=${MIRROR}/homebrew-bottles
  ```

* Update metadata cache

  ```bash
  brew udpate -v
  ```

* Verification, the version should be greater than 2.7.1

  ```bash
  brew --version
  Homebrew 2.7.1-22-g20ff74a
  Homebrew/homebrew-core (git revision ace0a; last commit 2020-12-28)
  ```

## Intel x86

* Install homebrew

    ```bash
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    ```

* Replace repo

    ```bash
    cd "$(brew --repo)"
    git remote set-url origin https://mirrors.ustc.edu.cn/brew.git
    ```

    ```bash
    cd "$(brew --repo)/Library/Taps/homebrew/homebrew-core"
    git remote set-url origin https://mirrors.ustc.edu.cn/homebrew-core.git
    ```

    ```bash
    cd "$(brew --repo)/Library/Taps/homebrew/homebrew-cask"
    git remote set-url origin https://mirrors.ustc.edu.cn/homebrew-cask.git
    ```

* Update metadata cache

    ```bash
    brew update -v
    ```

## install packages

* Replace bottle repo (for China only, f**k the GFW)
  * for bash

    ```bash
    echo 'export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles' >> ~/.bash_profile
    source ~/.bash_profile
    ```

  * for zsh

    ```bash
    echo 'export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles' >> ~/.zshrc
    source ~/.zshrc
    ```

* Install common packages

  ```bash
  brew install wget zsh-syntax-highlighting tree telnet ncdu gnu-sed graphviz
  ```

* Install other packages, note the following packages doesn't support m1 yet.

  ```bash
  brew install wireguard-tools kubectl
  ```