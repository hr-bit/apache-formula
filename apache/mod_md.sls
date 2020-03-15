{% from "apache/map.jinja" import apache with context %}

include:
  - apache

{% if grains['os_family']=="Debian" %}
enable-mod_md:
  apache_module.enabled:
    - name: md
    - watch_in:
      - module: apache-restart

{% set MDomains = '' %}
{% for mdid,mdsite in salt['pillar.get']('apache:sites', {}).items() %}
meh:
  cmd.run:
    - name: echo {{ mdid }}
    
{%   set vals = {
    'ServerName': mdsite.get('ServerName', ''),
    'ServerAlias': mdsite.get('ServerAlias', ''),
    'ManagedDomain': mdsite.get('ManagedDomain', True)
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

#{ if MDomains != '' %}
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
  apache_conf.enabled:
    - name: md
    - require:
      - file: mod_md-config
    - watch_in:
      - module: apache-restart
#{ endif %}

{% endif %}
