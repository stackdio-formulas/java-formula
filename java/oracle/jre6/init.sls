{% if grains['os_family'] == 'Debian' %}

# The webup8team PPA does not provide a JRE install, nor does
# Oracle provide deb files. For now, we're going to install
# the JDK from the PPA.
include:
  - java.oracle.jdk6

{% elif grains['os_family'] == 'RedHat' %}

# Staging directory
{% set staging  = pillar.java.oracle.staging %}
{% set cookies  = pillar.java.oracle.cookies %}
{% set java_bin = pillar.java.oracle.jre6.bin %}
{% set java_uri = pillar.java.oracle.jre6.uri + pillar.java.oracle.jre6.bin %}
{% set java_rpm = pillar.java.oracle.jre6.rpm %}

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

#clear_staging:
#  file:
#    - absent
#    - name: {{ staging }}
#    - require:
#      - cmd: install_java

{% endif %}

