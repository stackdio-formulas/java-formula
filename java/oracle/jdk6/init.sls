{% if grains['os_family'] == 'Debian' %}
# add the oracle apt repository
jdk6_repo:
  pkgrepo:
    - managed
    - ppa: webupd8team/java

# accept the license agreement for a headless install
jdk6_installer_selections:
  cmd:
    - run
    - name: 'echo oracle-java6-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections'
    - require:
      - pkgrepo: jdk6_repo

# ie, apt-get update
jdk6_refresh_db:
  module:
    - run
    - name: pkg.refresh_db
    - require:
      - pkgrepo: jdk6_repo

# JAVA_HOME globally
/etc/environment:
  file:
    - append
    - text: 'JAVA_HOME="{{ pillar.jdk6.java_home }}"'
    - require:
      - pkgrepo: jdk6_repo

# install java6
oracle-java6-installer:
  pkg:
    - installed
    - name: oracle-java6-installer
    - require:
      - cmd: jdk6_installer_selections
      - module: jdk6_refresh_db
      - file: /etc/environment

{% elif grains['os_family'] == 'RedHat' %}

# Staging directory
{% set staging  = pillar.java.oracle.staging %}
{% set cookies  = pillar.java.oracle.cookies %}
{% set java_bin = pillar.java.oracle.jdk6.bin %}
{% set java_uri = pillar.java.oracle.jdk6.uri + pillar.java.oracle.jdk6.bin %}
{% set java_rpm = pillar.java.oracle.jdk6.rpm %}

init_staging:
  file:
    - directory
    - name: {{ staging }}
    - makedirs: true
    - clean: true

wget:
  pkg:
    - installed

download_java:
  cmd:
    - run
    - cwd: {{ staging }}
    - name: 'wget --no-check-certificate --header="Cookie: {{ cookies }}" -c "{{ java_uri }}" -O "{{ java_bin }}"'
    - unless: 'rpm -qa | grep {{ java_rpm }}'
    - require:
      - pkg: wget
      - file: init_staging

install_java:
  cmd:
    - run
    - cwd: {{ staging }}
    - name: 'chmod 755 {{ java_bin }} && ./{{ java_bin }}'
    - unless: 'rpm -qa | grep {{ java_rpm }}'
    - require:
      - cmd: download_java 

clear_staging:
  file:
    - absent
    - name: {{ staging }}
    - require:
      - cmd: install_java

{% endif %}
