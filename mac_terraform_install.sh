# !/bin/bash

read -p "Enter terraform version: " version

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew_install_wget() {
    echo "\nInstalling $1"
    if brew list $1 &>/dev/null; then
        echo "${1} is already installed"
    else
        brew install $1 && echo "$1 is installed"
    fi
}
brew_install_wget "wget"

wget https://releases.hashicorp.com/terraform/$version/terraform_${version}_darwin_amd64.zip

brew_install_unzip() {
    echo "\nInstalling $1"
    if brew list $1 &>/dev/null; then
        echo "${1} is already installed"
    else
        brew install $1 && echo "$1 is installed"
    fi
}
brew_install_unzip "unzip"

unzip terraform_${version}_darwin_amd64.zip
chmod +x terraform
sudo mv terraform /usr/local/bin/
terraform --version
sudo rm -r terraform_${version}_darwin_amd64.zip