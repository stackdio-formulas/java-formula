
download_jce:
  cmd:
    - run
    - cwd: {{ staging }}
    - name: 'wget --no-check-certificate --header="Cookie: {{ cookies }}" -c "{{ jce_uri }}" -O jce.zip'
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
    - require:
      - cmd: download_jce
      - pkg: unzip

install_jce:
  cmd:
    - run
    - cwd: {{ staging }}
    - name: 'mv jce/*/*.jar /usr/java/latest/jre/lib/security'
    - unless: test -f /usr/java/latest/jre/lib/security/local_policy.jar
    - require:
      - cmd: install_java
      - cmd: unzip_jce
    - require_in:
      - file: clear_staging
