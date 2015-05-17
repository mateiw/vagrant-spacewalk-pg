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
  cmd.run:
    - name: PGPASSWORD=spacepw; createdb -E UTF8 spaceschema ; createlang plpgsql spaceschema ; createlang pltclu spaceschema ; yes $PGPASSWORD | createuser -P -sDR spaceuser
    - user: postgres
    - require:
        - pkg: install_spacewalk        
 
answer_file:
    file.managed:
        - name: /root/setup-answer.properties
        - source: salt://spacewalk/setup-answer.properties
        - require:
            - cmd: create_db 
            
spacewalk_setup:
  cmd.run:
    - name: spacewalk-setup --external-postgresql --answer-file=setup-answer.properties
    - cwd: /root
    - require:
        - file: answer_file
 
#su - postgres -c 'PGPASSWORD=spacepw; createdb -E UTF8 spaceschema ; createlang plpgsql spaceschema ; createlang pltclu spaceschema ; yes $PGPASSWORD | createuser -P -sDR spaceuser'    

#spacewalk-setup --external-postgresql --answer-file=setup-answer.properties