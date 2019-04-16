{% set java = salt['grains.filter_by']({
    'Debian': {
      'package': 'openjdk-8-jre'
    },
    'RedHat': {
      'package': 'java-1.8.0-openjdk'
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
    
/usr/java/latest/jre/lib/security/jssecacerts:
  file.copy:
    - source: /usr/java/latest/jre/lib/security/cacerts
    - preserve: true
    - require:
      - pkg: install_java

{% if salt['pillar.get']('ssl:ca_certificate', None) %}
/usr/java/latest/jre/lib/security/dr-root-ca.crt:
  file.managed:
    - user: root
    - group: root
    - mode: 444
    - contents_pillar: ssl:ca_certificate

import-dr-ca:
  cmd.run:
    - user: root
    - name: /usr/java/latest/bin/keytool -importcert -keystore /usr/java/latest/jre/lib/security/jssecacerts -storepass changeit -file /usr/java/latest/jre/lib/security/dr-root-ca.crt -alias dr-root-ca -noprompt
    - unless: /usr/java/latest/bin/keytool -list -keystore /usr/java/latest/jre/lib/security/jssecacerts -storepass changeit | grep dr-root-ca | grep trustedCertEntry
    - require:
      - file: /usr/java/latest/jre/lib/security/jssecacerts
      - file: /usr/java/latest/jre/lib/security/dr-root-ca.crt
{% endif %}
