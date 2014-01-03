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
{% set staging="/tmp/.jdk6_staging" %}
{% set cookies="oraclelicensejdk-6u45-oth-JPR=accept-securebackup-cookie;gpw_e24=http://edelivery.oracle.com" %}
{% set jdk6_bin="jdk-6u45-linux-x64-rpm.bin" %}
{% set jdk6_uri="http://download.oracle.com/otn-pub/java/jdk/6u45-b06/" ~ jdk6_bin %}
{% set jdk6_package="jdk-1.6.0_45" %}

{{ staging }}:
  file:
    - directory
    - makedirs: true
    - clean: true

wget:
  pkg:
    - installed

# download JDK6
download_jdk6:
  cmd:
    - run
    - cwd: {{ staging }}
    - name: 'wget --no-check-certificate --header="Cookie: {{ cookies }}" -c "{{ jdk6_uri }}" -O "{{ jdk6_bin }}"'
    - unless: 'rpm -qa | grep {{ jdk6_package }}'
    - require:
      - pkg: wget
      - file: {{ staging }}

install_jdk6:
  cmd:
    - run
    - cwd: {{ staging }}
    - name: 'chmod 755 {{ jdk6_bin }} && bash ./{{ jdk6_bin }}'
    - unless: 'rpm -qa | grep {{ jdk6_package }}'
    - require:
      - cmd: download_jdk6

{% endif %}
