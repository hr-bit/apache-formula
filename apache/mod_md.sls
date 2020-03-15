{% from "apache/map.jinja" import apache with context %}

include:
  - apache

{% if grains['os_family']=="Debian" %}
enable-mod_md:
  apache_module.enable:
    - name: md
    - watch_in:
      - module: apache-restart

{% set MDomains = '' %}
{% for id,site in salt['pillar.get']('apache:sites', {}).items() %}
{%   set vals = {
    'ServerName': site.get('ServerName', ''),
    'ServerAlias': site.get('ServerAlias', ''),
    'ManagedDomain': site.get('ManagedDomain', False)
} %}
{%   if vals.ManagedDomain == True %}
{%     if vals.ServerName != '' %}
{%       set MDomains = MDomains + " " + vals.ServerName %}
{%     endif %}
{%     if vals.ServerAlias != '' %}
{%       set MDomains = MDomains + " " + vals.ServerAlias %}
{%     endif %}
{%   endif %}
{% endfor %}

{% if MDomains != '' %}
mod_md-config:
  file.managed:
    - name: /etc/apache2/conf-available/md.conf
    - user: root
    - group: root
    - mode: 644
    - watch_in:
      - module: apache-restart
    - contents: |
        MDomain {{ MDomains }}
        MDCertificateAgreement accepted

mod_md-config-enable:
  apache_conf.enable:
    - name: md
    - require:
      - file: mod_md-config
    - watch_in:
      - module: apache-restart
{% endif %}

{% endif %}
