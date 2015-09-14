cleanprint-dependencies:
  pkg.installed:
    pkgs:
      - nautilus-actions
      - ghostscript

cleanprint-install:
  file.managed:
    - name: /usr/local/bin/cleanprint.sh
    - mode: 755
    - template: jinja
    - defaults:
        printer: "2015-A4-zweiseitig"
	- source: salt://cleanprint/cleanprint.sh

{% for username in salt['user.list_users']() %}
{% set details = salt['user.info'](username) %}
{% if details.uid >= 1000 and username != "nobody" %}
cleanprint-register-{{ username }}:
  cmd.run:
    - name: nautilus-actions-new -l "Print PDF" -t "Print PDF files" -x /usr/local/bin/cleanprint.sh -p "%f" -m "application/pdf" --desktop
    # TODO: add check if the menu item already exists as otherwise it is added again and again and again
    #- onlyif:
    #  - cmd: nautilus-actions-print "Print PDF" | grep cleanprint.sh # TODO: get validation of command is already installed right!
    - user: {{ username }}
{% endif %}
{% endfor %}  # add script to the context menu