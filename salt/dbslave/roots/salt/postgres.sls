add PGDG repo:  
  pkgrepo.managed:
    - name: pgdg
    - humanname: PostgreSQL Official Repo
    - baseurl: http://yum.postgresql.org/9.4/redhat/rhel-$releasever-$basearch
    - gpgcheck: 0
    - enabled: 1

install_postgres:
  pkg.installed:
    - pkgs: 
        - postgresql94-server
        - postgresql94
        - postgresql94-contrib

init db:
  cmd.run:
    - name: /usr/pgsql-9.4/bin/postgresql94-setup initdb
    - onlyif: test -d /var/lib/pgsql/9.4/data && test -z "$(ls -A /var/lib/pgsql/9.4/data/)"
    - require:
        - pkg: install_postgres    

make sure Postgresql is running:
  service.running:
    - name: postgresql-9.4
    - enable: True
    - require:
        - pkg: install_postgres
