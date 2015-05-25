install_pgpool:
  pkg.installed:
    - pkgs: 
        - pgpool-II-94
        - pgpool-II-94-extensions

pgpool.conf:
    file.managed:
        - name: /etc/pgpool-II-94/pgpool.conf
        - source: salt://pgpool/pgpool.conf
        - user: postgres
        - group: postgres
        - mode: 644
        - require:
            - pkg: install_pgpool        
            
pcp.conf:
    file.managed:
        - name: /etc/pgpool-II-94/pcp.conf
        - source: salt://pgpool/pcp.conf
        - user: postgres
        - group: postgres
        - mode: 644
        - require:
            - pkg: install_pgpool        
            
pool_hba.conf:            
    file.managed:
        - name: /etc/pgpool-II-94/pool_hba.conf
        - source: salt://pgpool/pool_hba.conf
        - user: postgres
        - group: postgres
        - mode: 644
        - require:
            - pkg: install_pgpool        
        
pool_passwd:            
    file.managed:
        - name: /etc/pgpool-II-94/pool_passwd
        - source: salt://pgpool/pool_passwd
        - user: postgres
        - group: postgres
        - mode: 644
        - require:
            - pkg: install_pgpool
        
failover.sh:
    file.managed:
        - name: /usr/local/bin/failover.sh
        - source: salt://pgpool/failover.sh
        - user: postgres
        - group: postgres
        - mode: 755
        - require:
            - file: pgpool.conf
            - pkg: install_pgpool
            
pgpool_sysconfig:
    file.managed:
        - name: /etc/sysconfig/pgpool-II-94
        - source: salt://pgpool/pgpool-II-94
        - user: root
        - group: root
        - mode: 644
        - require:
            - file: pgpool.conf
            - pkg: install_pgpool            
        
make sure pgpool is running:
  service.running:
    - name: pgpool-II-94 
    - enable: True
    - watch:
      - file: /etc/pgpool-II-94/pgpool.conf
    - require:
        - pkg: install_pgpool
        - file: pgpool_sysconfig
           
