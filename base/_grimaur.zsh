#compdef grimaur 
# file usr/share/zsh/site-functions/_grimaur

_grimaur() {
    local curcontext="$curcontext" state line
    typeset -A opt_args

    local -a global_opts
    global_opts=(
        '--dest-root[Directory to store cloned packages]:directory:_directories'
        '--refresh[Refresh existing clones before use]'
        '--no-color[Disable colored output]'
        '--aur-rpc[Use AUR RPC API (default)]'
        '--git-mirror[Use git mirror instead of AUR RPC]'
    )

    _arguments -C \
        $global_opts \
        '1: :->command' \
        '*:: :->args' \
        && return 0

    case $state in
        command)
            local -a commands
            commands=(
                'fetch:Clone the package branch locally'
                'install:Resolve dependencies and build/install a package'
                'remove:Remove an installed package'
                'update:Upgrade installed foreign packages'
                'search:Search packages via the configured backend'
                'inspect:Show PKGBUILD or dependency information'
                'list:List installed foreign (AUR) packages'
                'complete:Shell completion helper'
            )
            _describe -t commands 'grimaur command' commands
            ;;
        args)
            case $line[1] in
                fetch)
                    _arguments \
                        $global_opts \
                        '--force[Reclone even if directory exists]' \
                        '1:package:_grimaur_aur_packages'
                    ;;
                install)
                    _arguments \
                        $global_opts \
                        '--noconfirm[Pass --noconfirm to pacman/makepkg]' \
                        '1:package:_grimaur_aur_packages'
                    ;;
                remove)
                    _arguments \
                        $global_opts \
                        '--noconfirm[Pass --noconfirm to pacman]' \
                        '--remove-cache[Also remove the cached clone]' \
                        '1:package:_grimaur_foreign_packages'
                    ;;
                update)
                    _arguments \
                        $global_opts \
                        '--noconfirm[Pass --noconfirm to pacman/makepkg]' \
                        '--devel[Include VCS/devel packages]' \
                        '--global[Update official repositories with pacman -Syu first]' \
                        '*:packages:_grimaur_foreign_packages'
                    ;;
                search)
                    _arguments \
                        $global_opts \
                        '--regex[Treat pattern as regular expression]' \
                        '--limit[Limit results]:number:(10 20 50 100)' \
                        '--no-interactive[Disable interactive selection]' \
                        '--noconfirm[Skip confirmation prompts]' \
                        '1:pattern:'
                    ;;
                inspect)
                    _arguments \
                        $global_opts \
                        '--target[Which data to show]:target:(info PKGBUILD SRCINFO)' \
                        '--full[Include make/check/optional dependencies]' \
                        '1:package:_grimaur_aur_packages'
                    ;;
                list)
                    _arguments $global_opts
                    ;;
                complete)
                    _arguments \
                        '1:subcommand:(install)' \
                        '2:prefix:' \
                        '--limit[Limit number of candidates]:number:(64)'
                    ;;
            esac
            ;;
    esac
}

# Helper function to complete AUR package names
_grimaur_aur_packages() {
    local -a packages
    local prefix="$PREFIX"
    
    # Only try to complete if we have at least 2 characters
    if [[ ${#prefix} -ge 2 ]]; then
        packages=(${(f)"$(grimaur complete install "$prefix" 2>/dev/null)"})
        _describe -t packages 'AUR package' packages
    fi
}

# Helper function to complete installed foreign packages
_grimaur_foreign_packages() {
    local -a packages
    packages=(${(f)"$(pacman -Qmq 2>/dev/null)"})
    _describe -t packages 'installed package' packages
}

_grimaur "$@"
