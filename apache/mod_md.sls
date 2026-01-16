{% from "apache/map.jinja" import apache with context %}

include:
  - apache

{% if grains['os_family']=="Debian" %}
enable-mod_md:
  apache_module.enabled:
    - name: md
    - watch_in:
      - module: apache-restart

mod_md-config:
  file.managed:
    - name: /etc/apache2/conf-available/md.conf
    - user: root
    - group: root
    - mode: 644
    - watch_in:
      - module: apache-restart
    - contents: |
{%- for key,val in salt['pillar.get']('apache:md', {}).items() %}
        {{ key }} {{ val }}
{%- endfor %}

mod_md-config-enable:
  apache_conf.enabled:
    - name: md
    - require:
      - file: mod_md-config
    - watch_in:
      - module: apache-restart

#mod_md-permissions:
#  file.directory:
#    - name: /etc/apache2/md
#    - user: root
#    - group: root
#    - dir_mode: 600
#    - file_mode: 700
{% endif %}
