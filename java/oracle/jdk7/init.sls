# CentOS things
{% set staging  = pillar.java.oracle.staging %}
{% set cookies  = pillar.java.oracle.cookies %}
{% set java_uri = pillar.java.oracle.jdk7.uri %}
{% set java_rpm = pillar.java.oracle.jdk7.rpm %}
{% set jce_uri = pillar.java.oracle.jce7.uri %}

# Ubuntu things
{% set java_version = '7' %}

include:
  - java.java_home
  - java.oracle.install
