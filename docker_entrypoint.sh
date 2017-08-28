#!/bin/bash
set -e

python -c "from gluon.main import save_password; save_password('$PW',80)"
python -c "from gluon.main import save_password; save_password('$PW',443)"

if [ ! -f /etc/apache2/ssl/key.pem ]; then
    cat >&2 <<-EOT

    ERROR: No SSL key or cert found. A self-signed cert will be created for you.
    TO change the default cert-subject, set CERT_SUBJECT with: -e CERT_SUBJECT="/CN=monitutor.example.com"
    Please consider to get a valid certificate. You should run web2py with: -v key.pem:/etc/apache2/ssl/key.pem:ro -v cert.pem:/etc/apache2/ssl/cert.pem:ro

EOT
    cd /etc/apache2/ssl
    openssl genrsa 2048 > key.pem && chmod 400 key.pem
    openssl req -new -x509 -nodes -sha1 -days 3650 -subj $CERT_SUBJECT -key key.pem > cert.pem
    openssl x509 -noout -fingerprint -text < cert.pem > web2py.info
fi
if [[ $PW == "admin" ]]; then
    cat >&2 <<-EOT

    WARNING: Using default password "admin". You should run web2py with: -e PW=changeme

EOT
fi

exec "$@"
