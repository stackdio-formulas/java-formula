include:
  - java.java_home

{% if grains['os_family'] == 'Debian' %}

# The webup8team PPA does not provide a JRE install, nor does
# Oracle provide deb files. For now, we're going to install
# the JDK from the PPA.
  - java.oracle.jdk7

{% elif grains['os_family'] == 'RedHat' %}

# Staging directory
{% set staging  = pillar.java.oracle.staging %}
{% set cookies  = pillar.java.oracle.cookies %}
{% set java_uri = pillar.java.oracle.jre7.uri %}
{% set java_rpm = pillar.java.oracle.jre7.rpm %}

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
    - unless: test -f /usr/java/latest/jre/lib/security/local_policy.jar
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
    - unless: test -f /usr/java/latest/jre/lib/security/local_policy.jar
    - require:
      - cmd: download_jce
      - pkg: unzip

install_jce:
  cmd:
    - run
    - cwd: {{ staging }}
    - name: 'mv jce/*/*.jar /usr/java/latest/lib/security'
    - unless: test -f /usr/java/latest/jre/lib/security/local_policy.jar
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

