# Version: 0.0.1
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
    cd .. && \
	mv web2py/handlers/wsgihandler.py web2py/wsgihandler.py && \
    chown -R www-data:www-data web2py

# configure apache2
ADD apache-web2py.conf /etc/apache2/sites-available/
RUN a2ensite apache-web2py
RUN a2dissite 000-default
RUN a2enmod wsgi && a2enmod ssl && a2enmod proxy && a2enmod rewrite

ADD docker_entrypoint.sh /var/www/
RUN chmod o+x /var/www/docker_entrypoint.sh
RUN mkdir /etc/apache2/ssl
RUN chown -R www-data:www-data /var/www/

WORKDIR /var/www/web2py

# start apache2
CMD /var/www/docker_entrypoint.sh apache2ctl start && tail -F /var/log/apache2/*.log
