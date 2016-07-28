
{% if pillar.java.enable_jce %}
include:
  - java.oracle.jce
{% endif %}

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
    - name: 'echo oracle-java{{ java_version }}-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections'
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
oracle-java{{ java_version }}-installer:
  pkg:
    - installed
    - name: oracle-java{{ java_version }}-installer
    - require:
      - cmd: java_installer_selections
      - module: java_refresh_db

# Create symlink so java can be found in a normal location
/usr/java/jdk1.{{ java_version }}.0:
  file:
    - symlink
    - target: /usr/lib/jvm/java-{{ java_version }}-oracle
    - makedirs: true
    - require:
      - pkg: oracle-java{{ java_version }}-installer

# make the latest link
/usr/java/latest:
  file:
    - symlink
    - target: jdk1.{{ java_version }}.0
    - require:
      - file: /usr/java/jdk1.{{ java_version }}.0

{% elif grains['os_family'] == 'RedHat' %}

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

clear_staging:
  file:
    - absent
    - name: {{ staging }}
    - require:
      - cmd: install_java

{% endif %}
