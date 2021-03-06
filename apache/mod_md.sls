{% from "apache/map.jinja" import apache with context %}

include:
  - apache

{% if grains['os_family']=="Debian" %}
enable-mod_md:
  apache_module.enabled:
    - name: md
    - watch_in:
      - module: apache-restart

{% set MDomains = [] %}
{% for mdid,mdsite in salt['pillar.get']('apache:sites', {}).items() %}
{%   set vals = {
    'ServerName': mdsite.get('ServerName', ''),
    'ServerAlias': mdsite.get('ServerAlias', ''),
    'ManagedDomain': mdsite.get('ManagedDomain', False)
} %}

{%   if vals.ManagedDomain == True %}
{%     if vals.ServerName != '' %}
{%       do MDomains.append(vals.ServerName) %}
{%     endif %}
{%     if vals.ServerAlias != '' %}
{%       do MDomains.append(vals.ServerAlias) %}
{%     endif %}
{%   endif %}
{% endfor %}

{% if MDomains %}
mod_md-config:
  file.managed:
    - name: /etc/apache2/conf-available/md.conf
    - user: root
    - group: root
    - mode: 644
    - watch_in:
      - module: apache-restart
    - contents: |
        MDomain {{ MDomains|join(" ") }}
        MDCertificateAgreement accepted

mod_md-config-enable:
  apache_conf.enabled:
    - name: md
    - require:
      - file: mod_md-config
    - watch_in:
      - module: apache-restart
{% endif %}
{% endif %}
