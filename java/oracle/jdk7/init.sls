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
    - name: 'echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections'
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
oracle-java7-installer:
  pkg:
    - installed
    - name: oracle-java7-installer
    - require:
      - cmd: java_installer_selections
      - module: java_refresh_db

# Create symlink so java can be found in a normal location
/usr/java/jdk1.7.0:
  file:
    - symlink
    - target: /usr/lib/jvm/java-7-oracle
    - makedirs: true
    - require:
      - pkg: oracle-java7-installer

# make the latest link
/usr/java/latest:
  file:
    - symlink
    - target: jdk1.7.0
    - require:
      - file: /usr/java/jdk1.7.0


{% elif grains['os_family'] == 'RedHat' %}

# Staging directory
{% set staging  = pillar.java.oracle.staging %}
{% set cookies  = pillar.java.oracle.cookies %}
{% set java_uri = pillar.java.oracle.jdk7.uri %}
{% set java_rpm = pillar.java.oracle.jdk7.rpm %}

init_staging:
  file:
    - directory
    - name: {{ staging }}
    - makedirs: true
    - clean: true

wget:
  pkg:
    - installed

# Set the timeout to 2 minutes.  It looks like it usually takes around 80 seconds to download.
# Then let it retry 3 times.
download_java:
  cmd:
    - run
    - cwd: {{ staging }}
    - name: 'wget --no-check-certificate --timeout=120 --tries=3 --header="Cookie: {{ cookies }}" -c "{{ java_uri }}" -O "{{ java_rpm }}.rpm"'
    - unless: 'rpm -qa | grep {{ java_rpm }}'
    - require:
      - pkg: wget
      - file: init_staging

install_java:
  cmd:
    - run
    - cwd: {{ staging }}
    - name: 'rpm -Uvh {{ java_rpm }}.rpm'
    - unless: 'rpm -qa | grep {{ java_rpm }}'
    - require:
      - cmd: download_java

set_alternatives:
  cmd:
    - run
    - cwd: {{ staging }}
    - name: 'alternatives --install /usr/bin/java java /usr/java/latest/bin/java 1000000'
    - onlyif: 'rpm -qa | grep {{ java_rpm }}'
    - require:
      - cmd: install_java

{% if pillar.java.enable_jce %}
{% set jce_uri = pillar.java.oracle.jce7.uri %}

download_jce:
  cmd:
    - run
    - cwd: {{ staging }}
    - name: 'wget --no-check-certificate --header="Cookie: {{ cookies }}" -c "{{ jce_uri }}" -O jce.zip'
    - require:
      - pkg: wget
      - file: init_staging

unzip:
  pkg:
    - installed

unzip_jce:
  cmd:
    - run
    - cwd: {{ staging }}
    - name: 'unzip -d jce jce.zip'
    - require:
      - cmd: download_jce
      - pkg: unzip

install_jce:
  cmd:
    - run
    - cwd: {{ staging }}
    - name: 'mv jce/*/*.jar /usr/java/latest/jre/lib/security'
    - require:
      - cmd: unzip_jce
{% endif %}

clear_staging:
  file:
    - absent
    - name: {{ staging }}
    - require:
      - cmd: install_java
{% if pillar.java.enable_jce %}
      - cmd: install_jce
{% endif %}

{% endif %}

