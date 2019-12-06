# Version: 0.0.3
FROM debian:stable
MAINTAINER Mark Swillus "mark.swillus@alumni.fh-aachen.de"

ENV PW="admin"
ENV CERT_SUBJECT="/CN=monitutor.example.com"

WORKDIR /var/www

USER root

RUN apt-get update && \
    apt-get install  python-dev python-pip git apache2 libapache2-mod-wsgi -y && \
    apt-get clean

# get Web2Py from Github
RUN cd /var/www/ && git clone https://github.com/web2py/web2py.git && \
    cd web2py && \
    git submodule update --init --recursive && \
    git checkout 285013a64a12d5fcb353c8a8587d9ad4e806cac7 && \
    cd .. && \
	mv web2py/handlers/wsgihandler.py web2py/wsgihandler.py && \
    chown -R www-data:www-data web2py

# configure apache2
ADD apache-web2py.conf /etc/apache2/sites-available/
RUN a2ensite apache-web2py && \
    a2dissite 000-default && \
    a2enmod wsgi && a2enmod ssl && a2enmod proxy && a2enmod rewrite

ADD docker_entrypoint.sh /var/www/

RUN chmod u+x /var/www/docker_entrypoint.sh && \
    mkdir /etc/apache2/ssl && \
    chown -R www-data:www-data /var/www/

WORKDIR /var/www/web2py

# start apache2
ENTRYPOINT ["bash", "/var/www/docker_entrypoint.sh"]
CMD apache2ctl start && tail -F /var/log/apache2/*.log
