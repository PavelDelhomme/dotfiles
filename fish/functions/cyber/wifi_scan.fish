function wifi_scan
    sudo iwlist wlan0 scan | grep 'ESSID'
end

