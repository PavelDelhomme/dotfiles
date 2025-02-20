function check_ssl_cert
    echo | openssl s_client -servername $argv[1] -connect $argv[1]:443 2>/dev/null | openssl x509 -noout -dates -subject -issuer
end

