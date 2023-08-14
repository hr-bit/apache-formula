{% from "apache/map.jinja" import apache with context %}

include:
  - apache

mod-php8.2:
  pkg.installed:
    - name: {{ apache.mod_php74 }}
    - order: 180
    - require:
      - pkg: apache

{% if grains['os_family']=="Debian" %}
a2enmod php8.2:
  cmd.run:
    - unless: ls /etc/apache2/mods-enabled/php8.2.load
    - order: 225
    - require:
      - pkg: mod-php8.2
    - watch_in:
      - module: apache-restart

{% if 'apache' in pillar and 'php-ini' in pillar['apache'] %}
/etc/php/8.2/apache2/php.ini:
  file.managed:
    - source: {{ pillar['apache']['php-ini'] }}
    - order: 225
    - watch_in:
      - module: apache-restart
    - require:
      - pkg: apache
      - pkg: mod-php8.2
{% endif %}

{% endif %}
