##
## Generate ssh keys and add them to the slave to enable passwordless login from failover script
##

install_sshpass:
  pkg.installed:
    - pkgs: 
        - sshpass

generate_keys:
  cmd.run:
    - name: yes | ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
    - user: postgres

known_hosts:
  cmd.run:
    - name: ssh-keyscan 192.168.99.3 >> ~/.ssh/known_hosts | sort -u -o ~/.ssh/known_hosts
    - user: postgres
    
copy_key:
  cmd.run:
    - name: sshpass -p password ssh-copy-id postgres@192.168.99.3 
    - user: postgres
    - require:
        - pkg: install_sshpass
        - cmd: generate_keys

