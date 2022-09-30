#!/bin/zsh
#export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.aliyun.com/homebrew/homebrew-bottles
export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles

git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# set language for Maps
defaults write com.apple.Maps AppleLanguages '(zh-CN)'

brew install loginputmac
brew install jq
brew install wget
brew install zsh-syntax-highlighting
brew install tree
brew install telnet
brew install ncdu
brew install rename
brew install gnu-sed
brew install graphviz
brew install wireguard-tools
brew install openjdk
brew install helm
brew install rke
brew install kubernetes-cli@1.22
brew link kubernetes-cli@1.22

brew install azure-cli
#brew install terraform
brew install mas
brew install speedtest-cli
brew install cdrtools
brew install you-get
brew install musicbrainz-picard

brew install openssl@3
brew link openssl --force

brew install --cask font-jetbrains-mono
#brew install --cask shadowsocksx-ng
#brew install --cask clashx
brew install --cask alfred
#brew install --cask karabiner-elements
brew install --cask firefox
brew install --cask iterm2
brew install --cask typora
brew install --cask appcleaner
brew install --cask motrix
brew install --cask zoom
brew install --cask wireshark
brew install --cask teamviewer
brew install --cask vnc-viewer
brew install --cask sunloginclient
brew install --cask google-chrome
brew install --cask tableplus
brew install --cask iina
brew install --cask pycharm-ce
brew install --cask skype
brew install --cask microsoft-edge
brew install --cask visual-studio-code
brew install --cask postman
brew install --cask dash
brew install --cask tunnelblick
brew install --cask baidunetdisk
brew install --cask timemachineeditor
#brew install --cask monitorcontrol
#brew install --cask microsoft-azure-storage-explorer
brew install --cask musescore
brew install --cask tinymediamanager
brew install --cask handbrake
brew install --cask tencent-lemon

brew install --cask qlmarkdown
brew install --cask quicklook-json
brew install --cask quicklook-csv


# 497799835 Xcode
mas install 497799835

# 1542271266 Silicon Info
mas install 1542271266

# 1485844094 iShot Pro
mas install 1485844094

# 441258766 Magnet
mas install 441258766

# 1518036000 Sequel Ace
mas install 1518036000

# 408981434 iMovie
mas install 408981434

# 409183694 Keynote
mas install 409183694

# 1289583905 Pixelmator Pro
mas install 1289583905

# 472226235 LanScan
mas install 472226235

# 470158793 Keka
mas install 470158793

# 1449962996 Tencent Lemon Lite
#mas install 1449962996

# 966085870 TickTick
mas install 966085870

# 1231336508 Tencent Live
mas install 1231336508

# 1014945607 Youku Live
mas install 1014945607

# 600925318 Parallels Client
mas install 600925318

# 491854842 YoudaoDict
mas install 491854842

# 944848654 Netease Music
mas install 944848654

# 451108668 QQ
mas install 451108668

# 595615424 QQ Music
mas install 595615424

# 836500024 WeChat
mas install 836500024

# 1443749478 WPS
mas install 1443749478

# 1435447041 DingTalk Desktop
mas install 1435447041

# 664513913 Futubull
mas install 664513913

# 1529999940 Tiktok maker
mas install 1529999940

# 1144400433 EastMoney
mas install 1144400433
