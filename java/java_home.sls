/etc/profile.d/java.sh:
  file:
    - managed
    - user: root
    - group: root
    - mode: 644
    - makedirs: true
    - contents: 'export JAVA_HOME=/usr/java/latest'
