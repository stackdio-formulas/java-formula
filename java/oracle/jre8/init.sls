# CentOS things
{% set staging  = pillar.java.oracle.staging %}
{% set cookies  = pillar.java.oracle.cookies %}
{% set java_uri = pillar.java.oracle.jre8.uri %}
{% set java_rpm = pillar.java.oracle.jre8.rpm %}
{% set jce_uri = pillar.java.oracle.jce8.uri %}

# Ubuntu things
{% set java_version = '8' %}

include:
  - java.java_home
  - java.oracle.install
