{% set settings = salt['grains.filter_by']({
    'Debian': {
      'bashrc': '/etc/bash.bashrc'
    },
    'RedHat': {
      'bashrc': '/etc/bashrc'
    },
}) %}

/etc/profile.d/java.sh:
  file:
    - managed
    - user: root
    - group: root
    - mode: 644
    - makedirs: true
    - contents: 'export JAVA_HOME=/usr/java/latest'

{{ settings.bashrc }}:
  file:
    - sed
    - before: ''
    - after: 'export JAVA_HOME=/usr/java/latest'
    - flags': '^$'

