# CentOS things
{% set staging  = pillar.java.oracle.staging %}
{% set cookies  = pillar.java.oracle.cookies %}
{% set java_uri = pillar.java.oracle.jdk6.uri %}
{% set java_rpm = pillar.java.oracle.jdk6.rpm %}
{% set jce_uri = pillar.java.oracle.jce6.uri %}

# Ubuntu things
{% set java_version = '6' %}

include:
  - java.java_home
  - java.oracle.install
