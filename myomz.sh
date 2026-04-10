#!/bin/sh
# MyOMZ! Script
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
    REMOVE_COMMENTS=false
    while [ $# -gt 0 ]; do
        case "$1" in
            --single-user-install)
                SINGLE_USER_INSTALL=true
                ;;
            --remove-comments)
                REMOVE_COMMENTS=true
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
    local max_retries=3
    local retry_count=0
    
    echo "Attempting to download script from: $url"
    echo "Using $USED_DOWNLOADER to download..."

    while [ $retry_count -lt $max_retries ]; do
        if [ "$USED_DOWNLOADER" = "curl" ]; then
            if curl -fLo "$dest" "$url" 2>/dev/null; then
                break
            fi
        elif [ "$USED_DOWNLOADER" = "wget" ]; then
            if wget -q -O "$dest" "$url" 2>/dev/null; then
                break
            fi
        fi
        
        retry_count=$((retry_count + 1))
        if [ $retry_count -lt $max_retries ]; then
            echo "Download failed, retrying... (attempt $((retry_count + 1))/$max_retries)"
            sleep 2
        fi
    done

    if [ ! -f "$dest" ] || [ ! -s "$dest" ]; then
        echo "ERROR: Download failed after $max_retries attempts. The script could not be saved at $dest."
        echo "Check network connection or URL accessibility."
        exit 1
    fi
    echo "Download successful, saved to $dest"
}

install_plugin() {
    local repo_url="$1"
    local dest_dir="$2"
    local max_retries=3
    local retry_count=0

    echo "Cloning plugin from $repo_url to $dest_dir"
    
    while [ $retry_count -lt $max_retries ]; do
        if git clone --depth 1 "$repo_url" "$dest_dir" 2>/dev/null; then
            echo "Plugin cloned successfully."
            return 0
        fi
        
        retry_count=$((retry_count + 1))
        if [ $retry_count -lt $max_retries ]; then
            echo "Clone failed, retrying... (attempt $((retry_count + 1))/$max_retries)"
            rm -rf "$dest_dir"
            sleep 2
        fi
    done
    
    echo "ERROR: Failed to clone $repo_url after $max_retries attempts"
    exit 1
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

remove_comments_from_zshrc() {
    local zshrc_file="$1"
    local temp_file="${zshrc_file}.tmp"
    
    echo "Removing comments from zshrc..."
    
    # Remove lines that start with # (comments) but keep shebang and important lines
    # Also remove empty lines and inline comments
    if is_macos; then
        sed -E '/^[[:space:]]*#/d; /^[[:space:]]*$/d' "$zshrc_file" > "$temp_file"
    else
        sed -E '/^[[:space:]]*#/d; /^[[:space:]]*$/d' "$zshrc_file" > "$temp_file"
    fi
    
    mv "$temp_file" "$zshrc_file"
    echo "Comments removed from zshrc."
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

    echo "MyOMZ Script - by Remi 2021-2026"
    echo ""
    echo "Pick a source:"
    echo "[G] - GitHub -- Best compatibility, but may be slow in China Mainland."
    echo "[C] - GitHub China Proxy  -- Use proxy service to accelerate GitHub access in China Mainland. Unstable."
    echo "[P] - Custom GitHub Proxy -- Enter your own GitHub proxy URL prefix."
    read -p "Select > " MIRRORANSWER

    GITHUB_PROXY_PREFIX=""
    
    case "$MIRRORANSWER" in
        G|g)
            GITHUB_PROXY_PREFIX=""
            ;;
        C|c)
            GITHUB_PROXY_PREFIX="https://gh-proxy.com"
            ;;
        P|p)
            echo ""
            echo "Enter your custom GitHub proxy URL prefix."
            echo "Example: https://gh-proxy.com"
            echo "The script will append the GitHub raw content URL after your prefix."
            echo "Leave empty to use GitHub directly."
            read -p "Proxy prefix > " GITHUB_PROXY_PREFIX
            # Remove trailing slash if present
            GITHUB_PROXY_PREFIX="${GITHUB_PROXY_PREFIX%/}"
            ;;
        *)
            echo "FATAL: Invalid selection."
            exit 1
            ;;
    esac

    echo "Now downloading install script.."

    rm -f /tmp/omz_install.sh

    OMZ_INSTALL_URL="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
    if [ -n "$GITHUB_PROXY_PREFIX" ]; then
        OMZ_INSTALL_URL="${GITHUB_PROXY_PREFIX}/${OMZ_INSTALL_URL}"
    fi
    download_script "$OMZ_INSTALL_URL" "/tmp/omz_install.sh"

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
    SYNTAX_HIGHLIGHTING_URL="https://github.com/zsh-users/zsh-syntax-highlighting.git"
    if [ -n "$GITHUB_PROXY_PREFIX" ]; then
        SYNTAX_HIGHLIGHTING_URL="${GITHUB_PROXY_PREFIX}/${SYNTAX_HIGHLIGHTING_URL}"
    fi
    install_plugin "$SYNTAX_HIGHLIGHTING_URL" "$INSTALL_PATH/plugins/zsh-syntax-highlighting"

    echo "Now installing zsh-autosuggestions."
    AUTOSUGGESTIONS_URL="https://github.com/zsh-users/zsh-autosuggestions.git"
    if [ -n "$GITHUB_PROXY_PREFIX" ]; then
        AUTOSUGGESTIONS_URL="${GITHUB_PROXY_PREFIX}/${AUTOSUGGESTIONS_URL}"
    fi
    install_plugin "$AUTOSUGGESTIONS_URL" "$INSTALL_PATH/plugins/zsh-autosuggestions"

    echo "Applying patched zshrc file.."
    cp "$INSTALL_PATH/templates/zshrc.zsh-template" ~/.zshrc
    
    if [ "$REMOVE_COMMENTS" = true ]; then
        remove_comments_from_zshrc ~/.zshrc
    fi

    echo ""
    echo "------------------"
    echo "All done! Run zsh to try it out."
    echo "If you want to let oh-my-zsh work for another user, switch to that user and execute:"
    echo "cp $INSTALL_PATH/templates/zshrc.zsh-template ~/.zshrc"

    exit 0
}

main "$@"
