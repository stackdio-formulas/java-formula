{% if grains['os_family'] == 'Debian' %}

openjdk-6-jdk:
  pkg:
    - installed

{% elif grains['os_family'] == 'RedHat' %}

java-1.6.0-openjdk-devel:
  pkg:
    - installed

{% endif %}
