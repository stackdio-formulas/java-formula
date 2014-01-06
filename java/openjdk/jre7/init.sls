{% if grains['os_family'] == 'Debian' %}

openjdk-7-jre:
  pkg:
    - installed

{% elif grains['os_family'] == 'RedHat' %}

java-1.7.0-openjdk:
  pkg:
    - installed

{% endif %}
