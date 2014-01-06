{% if grains['os_family'] == 'Debian' %}
#
# TODO
#
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

download_java:
  cmd:
    - run
    - cwd: {{ staging }}
    - name: 'wget --no-check-certificate --header="Cookie: {{ cookies }}" -c "{{ java_uri }}" -O "{{ java_rpm }}.rpm"'
    - unless: 'rpm -qa | grep {{ java_rpm }}'
    - require:
      - pkg: wget
      - file: init_staging

install_java:
  cmd:
    - run
    - cwd: {{ staging }}
    - name: 'rpm -Uvh {{ java_rpm }}.rpm'
    - require:
      - cmd: download_java

clear_staging:
  file:
    - absent
    - name: {{ staging }}
    - require:
      - cmd: install_java

{% endif %}

