{% set settings = salt['grains.filter_by']({
    'Debian': {
      'bashrc': '/etc/bash.bashrc',
      'marker_start': '# System-wide .bashrc file for interactive bash(1) shells.',
      'marker_end': '# To enable the settings / commands in this file for login shells as well,',
      'java_home': '/usr/java/latest',
    },
    'RedHat': {
      'bashrc': '/etc/bashrc',
      'marker_start': '# /etc/bashrc',
      'marker_end': '# System wide functions and aliases',
      'java_home': '/usr/java/latest',
    },
}) %}

/etc/profile.d/java.sh:
  file:
    - managed
    - user: root
    - group: root
    - mode: 644
    - makedirs: true
    - contents: 'export JAVA_HOME={{ settings.java_home }}'

{{ settings.bashrc }}:
  file:
    - blockreplace
    - marker_start: '{{ settings.marker_start }}'
    - marker_end: '{{ settings.marker_end }}'
    - content: |
        export JAVA_HOME={{ settings.java_home }}
