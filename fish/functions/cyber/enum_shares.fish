function enum_shares
    set ip_cible $argv[1]
    smbclient -L "\\\\$ip_cible" -N
end

