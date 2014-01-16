{% set java = salt['grains.filter_by']({
    'Debian': {
      'package': 'openjdk-6-jre'
    },
    'RedHat': {
      'package': 'java-1.6.0-openjdk'
    },
}) %}


install_java:
  pkg:
    - installed
    - name: {{ java.package }}

/usr/java/latest:
  file:
    - symlink
    - target: /etc/alternatives/jre
    - makedirs: true
