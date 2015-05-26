add Spacewalk nightly repo:
  pkgrepo.managed:
    - name: spacewalk-nightly
    - humanname: Spacewalk nightly
    - baseurl: http://yum.spacewalkproject.org/nightly/RHEL/7/$basearch/
    - gpgcheck: 0
    - enabled: 1
    
add jpackage repo:
  pkgrepo.managed:
    - name: jpackage
    - humanname: jpackage repo
    - baseurl: http://mirrors.dotsrc.org/pub/jpackage/5.0/generic/free/
    - gpgcheck: 0
    - enabled: 1

install_spacewalk:
  pkg.installed:
    - pkgs:
        - spacewalk-postgresql

create_db:
  postgres_database.present:
    - name: spaceschema
    - encoding: UTF8

create_lang_plpgsql:
  cmd.run:
    - name: createlang plpgsql spaceschema
    - user: postgres
    - unless: createlang -d spaceschema -l | grep plpgsql
    - require:
        - postgres_database: create_db
        
create_lang_pltclu:
  cmd.run:
    - name: createlang pltclu spaceschema
    - user: postgres
    - unless: createlang -d spaceschema -l | grep pltclu
    - require:
        - postgres_database: create_db        
   
create_db_user:
  cmd.run:
    - name: psql -c "DROP ROLE IF EXISTS spaceuser; CREATE ROLE spaceuser PASSWORD 'spacepw' SUPERUSER CREATEDB CREATEROLE INHERIT LOGIN;"
    - user: postgres
    - require:
        - cmd: create_lang_plpgsql
        - cmd: create_lang_pltclu
 
answer_file:
    file.managed:
        - name: /root/setup-answer.properties
        - source: salt://spacewalk/setup-answer.properties
            
pgpool_running:
  service.running:
    - name: pgpool-II-94 
            
spacewalk_setup:
  cmd.run:
    - name: spacewalk-setup --external-postgresql --non-interactive --answer-file=setup-answer.properties
    - cwd: /root
    - require:
        - file: answer_file
        - service: pgpool_running
        - postgres_database: create_db
        - cmd: create_db_user