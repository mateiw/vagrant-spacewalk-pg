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
        
postgres_is_stopped:
  service.dead:
    - name: postgresql-9.4

delete_data_dir:
  cmd.run:
    - name: rm -rf /var/lib/pgsql/9.4/data
    - user: postgres
    - require: 
        - service: postgres_is_stopped
        
replicate_master:
  cmd.run:
    - name: pg_basebackup -P -R -X stream -c fast -h 192.168.99.2 -U postgres -D /var/lib/pgsql/9.4/data
    - user: postgres
    - require: 
        - cmd: delete_data_dir

recovery.conf:
    file.managed:
        - name: /var/lib/pgsql/9.4/data/recovery.conf
        - source: salt://postgresql/recovery.conf
        - user: postgres
        - group: postgres
        - mode: 600
        - require:
            - cmd: replicate_master
            
make sure Postgresql is running:
  service.running:
    - name: postgresql-9.4
    - enable: True
    - require:
        - file: recovery.conf

        
#init_db:
#  cmd.run:
#    - name: /usr/pgsql-9.4/bin/postgresql94-setup initdb
#    - onlyif: test -d /var/lib/pgsql/9.4/data && test -z "$(ls -A /var/lib/pgsql/9.4/data/)"
#    - require:
#        - pkg: install_postgres    
#
#pg_hba.conf:
#    file.managed:
#        - name: /var/lib/pgsql/9.4/data/pg_hba.conf
#        - source: salt://postgresql/pg_hba.conf
#        - user: postgres
#        - group: postgres
#        - mode: 600
#        - require:
#            - cmd: init_db
#            
#postgresql.conf:
#    file.managed:
#        - name: /var/lib/pgsql/9.4/data/postgresql.conf
#        - source: salt://postgresql/postgresql.conf
#        - user: postgres
#        - group: postgres
#        - mode: 600
#        - require:
#            - cmd: init_db
#            
#make sure Postgresql is running:
#  service.running:
#    - name: postgresql-9.4
#    - enable: True
#    - watch:
#      - file: /var/lib/pgsql/9.4/data/pg_hba.conf
#      - file: /var/lib/pgsql/9.4/data/postgresql.conf
#    - require:
#        - file: postgresql.conf
#