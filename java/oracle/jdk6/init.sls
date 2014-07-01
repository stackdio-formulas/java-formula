include:
  - java.java_home

{% if grains['os_family'] == 'Debian' %}

# add the oracle apt repository
java_repo:
  pkgrepo:
    - managed
    - ppa: webupd8team/java

# accept the license agreement for a headless install
java_installer_selections:
  cmd:
    - run
    - name: 'echo oracle-java6-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections'
    - require:
      - pkgrepo: java_repo

# ie, apt-get update
java_refresh_db:
  module:
    - run
    - name: pkg.refresh_db
    - require:
      - pkgrepo: java_repo

# install java
oracle-java6-installer:
  pkg:
    - installed
    - name: oracle-java6-installer
    - require:
      - cmd: java_installer_selections
      - module: java_refresh_db

# Create symlinks so that java can be found in a normal location
/usr/java/jdk1.6.0:
  file:
    - symlink
    - target: /usr/lib/jvm/java-6-oracle
    - makedirs: true
    - require:
      - pkg: oracle-java6-installer

# make latest link
/usr/java/latest:
  file:
    - symlink
    - target: jdk1.6.0
    - require:
      - file: /usr/java/jdk1.6.0


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
