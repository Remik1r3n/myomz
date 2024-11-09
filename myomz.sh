#!/bin/sh
# MyOMZ! Script Debugging Version
# GitHub URL: https://github.com/Remik1r3n/myomz/
# by Remik1r3n

command_exists() {
    command -v "$@" >/dev/null 2>&1
}

is_macos() {
    [ "$(uname)" = "Darwin" ]
}

parse_arguments() {
    SINGLE_USER_INSTALL=false
    while [ $# -gt 0 ]; do
        case "$1" in
            --single-user-install)
                SINGLE_USER_INSTALL=true
                ;;
            *)
                echo "Unknown argument: $1"
                exit 1
                ;;
        esac
        shift
    done
}

self_check() {
    echo "Checking dependencies..."
    if ! command_exists zsh; then
        echo "FATAL: zsh is not installed. Please install it first."
        exit 1
    fi

    if command_exists wget; then
        USED_DOWNLOADER='wget'
    elif command_exists curl; then
        echo "WARNING: wget is not installed, falling back to curl."
        USED_DOWNLOADER='curl'
    else
        echo "FATAL: Neither wget nor curl is installed. Please install one or both."
        exit 1
    fi
    echo "Downloader set to: $USED_DOWNLOADER"

    if ! command_exists git; then
        echo "FATAL: git is not installed. Please install it first."
        exit 1
    fi

    if [ "$SINGLE_USER_INSTALL" = false ] && ! is_macos && [ "$(id -u)" -ne 0 ]; then
        echo "FATAL: Please run as root."
        exit 1
    fi
}

download_script() {
    local url="$1"
    local dest="$2"
    echo "Attempting to download script from: $url"
    echo "Using $USED_DOWNLOADER to download..."

    if [ "$USED_DOWNLOADER" = "curl" ]; then
        curl -Lo "$dest" "$url"
    elif [ "$USED_DOWNLOADER" = "wget" ]; then
        wget -O "$dest" "$url"
    fi

    if [ ! -f "$dest" ]; then
        echo "ERROR: Download failed. The script could not be saved at $dest."
        echo "Check network connection or URL accessibility."
        exit 1
    fi
    echo "Download successful, saved to $dest"
}

install_plugin() {
    local repo_url="$1"
    local dest_dir="$2"

    echo "Cloning plugin from $repo_url to $dest_dir"
    git clone "$repo_url" "$dest_dir" || { echo "ERROR: Failed to clone $repo_url"; exit 1; }
}

patch_zshrc() {
    local zshrc_template="$1"
    local install_path="$2"

    # Use different sed syntax for macOS and Linux
    if is_macos; then
        sed -i '' "s#\$HOME/.oh-my-zsh#$install_path#g" "$zshrc_template"
        sed -i '' "s#robbyrussell#gentoo#g" "$zshrc_template"
        sed -i '' "s#plugins=(git)#plugins=(git extract sudo zsh-syntax-highlighting zsh-autosuggestions)#g" "$zshrc_template"
    else
        sed -i "s#\$HOME/.oh-my-zsh#$install_path#g" "$zshrc_template"
        sed -i "s#robbyrussell#gentoo#g" "$zshrc_template"
        sed -i "s#plugins=(git)#plugins=(git extract sudo zsh-syntax-highlighting zsh-autosuggestions)#g" "$zshrc_template"
    fi
}

main() {
    parse_arguments "$@"
    self_check

    if [ "$SINGLE_USER_INSTALL" = true ] || is_macos; then
        echo "Using single user install! Running in macOS?"
        echo "!!! Note that You will NOT be able to use oh-my-zsh in other users !!!"
        INSTALL_PATH="$HOME/.oh-my-zsh"
        
    else
        INSTALL_PATH="/usr/share/oh-my-zsh"
    fi

    echo "MyOMZ Script - by Remi 2021-2024"
    echo ""
    echo "Pick a mirror:"
    echo "[G] - GitHub -- Best compatibility, but may be slow in China Mainland."
    echo "[C] - China  -- Use proxy service to accelerate GitHub access in China Mainland. Unstable."
    echo "[E] - Gitee -- Alternative for China Mainland. May be outdated."
    read -p "Select > " MIRRORANSWER

    echo "Now downloading install script.."

    rm -f /tmp/omz_install.sh

    case "$MIRRORANSWER" in
        G|g)
            download_script "https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh" "/tmp/omz_install.sh"
            ;;
        C|c)
            download_script "https://gh-proxy.com/https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh" "/tmp/omz_install.sh"
            ;;
        E|e)
            download_script "https://gitee.com/mirrors/oh-my-zsh/raw/master/tools/install.sh" "/tmp/omz_install.sh"
            ;;
        *)
            echo "FATAL: Invalid selection."
            exit 1
            ;;
    esac

    chmod +x /tmp/omz_install.sh

    echo "----- RUNNING OH-MY-ZSH INSTALL SCRIPT -----"
    RUNZSH=no ZSH="$INSTALL_PATH" /tmp/omz_install.sh
    if [ $? -ne 0 ]; then
        echo "ERROR: Install script returned an error! INSTALLATION FAILED!!"
        exit 1
    fi

    echo "----- OH-MY-ZSH INSTALL SCRIPT COMPLETED -----"
    cp "$INSTALL_PATH/templates/zshrc.zsh-template" "$INSTALL_PATH/templates/zshrc.zsh-template.original.bak"
    rm -f ~/.zshrc

    echo "Now patching zshrc file.."
    patch_zshrc "$INSTALL_PATH/templates/zshrc.zsh-template" "$INSTALL_PATH"

    echo "Now installing zsh-syntax-highlighting."
    install_plugin "https://github.com/zsh-users/zsh-syntax-highlighting.git" "$INSTALL_PATH/plugins/zsh-syntax-highlighting"

    echo "Now installing zsh-autosuggestions."
    install_plugin "https://github.com/zsh-users/zsh-autosuggestions.git" "$INSTALL_PATH/plugins/zsh-autosuggestions"

    echo "Applying patched zshrc file.."
    cp "$INSTALL_PATH/templates/zshrc.zsh-template" ~/.zshrc

    echo ""
    echo "------------------"
    echo "All done! Run zsh to try it out."
    echo "If you want to let oh-my-zsh work for another user, switch to that user and execute:"
    echo "cp $INSTALL_PATH/templates/zshrc.zsh-template ~/.zshrc"

    exit 0
}

main "$@"
