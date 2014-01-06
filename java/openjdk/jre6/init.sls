{% if grains['os_family'] == 'Debian' %}
#
# TODO
#
{% elif grains['os_family'] == 'RedHat' %}

java-1.6.0-openjdk:
  pkg:
    - installed

{% endif %}
