function recon_domain
    set domaine $argv[1]
    whois $domaine
    dig $domaine any +multiline +noall +answer
    theHarvester -d $domaine -l 500 -b all
end

