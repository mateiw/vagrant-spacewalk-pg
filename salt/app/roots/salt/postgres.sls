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
        - postgresql94-pltcl

init_db:
  cmd.run:
    - name: /usr/pgsql-9.4/bin/postgresql94-setup initdb
    - onlyif: test -d /var/lib/pgsql/9.4/data && test -z "$(ls -A /var/lib/pgsql/9.4/data/)"
    - require:
        - pkg: install_postgres    

pg_hba.conf:
    file.managed:
        - name: /var/lib/pgsql/9.4/data/pg_hba.conf
        - source: salt://postgresql/pg_hba.conf
        - user: postgres
        - group: postgres
        - mode: 600
        - require:
            - cmd: init_db
            
postgresql.conf:
    file.managed:
        - name: /var/lib/pgsql/9.4/data/postgresql.conf
        - source: salt://postgresql/postgresql.conf
        - user: postgres
        - group: postgres
        - mode: 600
        - require:
            - cmd: init_db
            
make sure Postgresql is running:
  service.running:
    - name: postgresql-9.4
    - enable: True
    - watch:
      - file: /var/lib/pgsql/9.4/data/pg_hba.conf
      - file: /var/lib/pgsql/9.4/data/postgresql.conf
    - require:
        - file: postgresql.conf
        
create replication slot:
  cmd.run:
    - name: psql -c "SELECT * FROM pg_create_physical_replication_slot('standby_replication_slot')"
    - user: postgres
    - onlyif: test "$(psql -A -t -c "SELECT count(*) FROM pg_replication_slots WHERE slot_name='standby_replication_slot'")" = "0"
        