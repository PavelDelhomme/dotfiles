function enumerate_users
    set ip $argv[1]
    enum4linux -a $ip
end

