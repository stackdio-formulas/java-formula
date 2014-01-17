{% set java = salt['grains.filter_by']({
    'Debian': {
      'package': 'openjdk-7-jre'
    },
    'RedHat': {
      'package': 'java-1.7.0-openjdk'
    },
}) %}

include:
  - java.java_home

install_java:
  pkg:
    - installed
    - name: {{ java.package }}

/usr/java/latest:
  file:
    - symlink
    - target: /etc/alternatives/jre
    - makedirs: true
