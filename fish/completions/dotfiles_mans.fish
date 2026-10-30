# Complétions Fish pour les *man (share/completions/mans.conf)
# Chargé depuis fish/config_custom.fish

function __dotfiles_mans_conf
    echo (set -q DOTFILES_DIR; and echo $DOTFILES_DIR; or echo $HOME/dotfiles)/share/completions/mans.conf
end

function __dotfiles_mans_subs --argument-names cmd
    set -l conf (__dotfiles_mans_conf)
    test -f $conf; or return
    set -l line (grep -E "^$cmd:" $conf 2>/dev/null | head -1 | string split -m1 ':' --)[2]
    echo help -h --help menu --interactive $line
end

function __dotfiles_mans_register
    set -l conf (__dotfiles_mans_conf)
    test -f $conf; or return
    for line in (cat $conf)
        string match -qr '^\s*#' -- $line; and continue
        string match -qr '^\s*$' -- $line; and continue
        set -l cmd (string split -m1 ':' -- $line)[1]
        test -n "$cmd"; or continue
        complete -c $cmd -e 2>/dev/null
        complete -c $cmd -n __fish_use_subcommand -a "(__dotfiles_mans_subs $cmd)" -d 'sous-commande *man'
        # dig niveau 2
        if test "$cmd" = netman
            complete -c netman -n '__fish_seen_subcommand_from dig' -a 'help A AAAA MX NS TXT SOA CNAME ANY +trace -x --raw @1.1.1.1 @8.8.8.8' -d 'dig'
        end
        if test "$cmd" = helpman
            set -l mdir (set -q DOTFILES_DIR; and echo $DOTFILES_DIR; or echo $HOME/dotfiles)/core/managers
            if test -d $mdir
                complete -c helpman -n __fish_use_subcommand -a "(path basename $mdir/*)" -d 'manager'
            end
        end
        if test "$cmd" = dfm -o "$cmd" = dfmenu
            set -l menudir (set -q DOTFILES_DIR; and echo $DOTFILES_DIR; or echo $HOME/dotfiles)/share/menus
            if test -d $menudir
                complete -c $cmd -n __fish_use_subcommand -a "(path basename -s .menu $menudir/*.menu)" -d 'menu'
            end
        end
    end
end

__dotfiles_mans_register
