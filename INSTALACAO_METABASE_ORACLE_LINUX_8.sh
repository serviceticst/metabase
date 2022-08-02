#------------------------------------------------
#   INSTALACAO AUTOMATIZADA GRAFANA NO ORACLE LINUX 8
#------------------------------------------------
#
#  Desenvolvido por: Service TIC Solucoes Tecnologicas
#            E-mail: contato@servicetic.com.br
#              Site: www.servicetic.com.br
#          Linkedin: https://www.linkedin.com/company/serviceticst
#          Intagram: https://www.instagram.com/serviceticst
#          Facebook: https://www.facebook.com/serviceticst
#           Twitter: https://twitter.com/serviceticst
#           YouTube: https://youtube.com/c/serviceticst
#            GitHub: https://github.com/serviceticst
#
#-------------------------------------------------
#
clear
echo "#-----------------------------------------#"
echo       "INSTALANDO PACOTES NECESSARIOS"
echo "#-----------------------------------------#"
dnf install epel-release -y
dnf install wget -y
clear
echo "#-----------------------------------------#"
echo       "INSTALANDO java-11-openjdk"
echo "#-----------------------------------------#"
dnf install java-11-openjdk-devel -y
clear
echo "#-----------------------------------------#"
echo   "BAIXANDO METABASE EM /usr/share/metabase"
echo "#-----------------------------------------#"
mkdir /usr/share/metabase &&
cd /usr/share/metabase &&
wget https://downloads.metabase.com/v0.43.4/metabase.jar &&
clear
echo "#-----------------------------------------#"
echo          "APLICANDO PERMISSOES"
echo "#-----------------------------------------#"
groupadd --system metabase
useradd --system -g metabase --no-create-home metabase
chown -R metabase:metabase /usr/share/metabase
touch /var/log/metabase.log
chown metabase:metabase /var/log/metabase.log
touch /etc/default/metabase
chmod 640 /etc/default/metabase
clear
echo "#-----------------------------------------#"
echo          "CRIANDO ARQUIVO DE LOG"
echo "#-----------------------------------------#"
clear
touch /etc/rsyslog.d/metabase.conf
echo ":msg,contains,"metabase" /var/log/metabase.log" >> /etc/rsyslog.d/metabase.conf
echo "& stop" >> /etc/rsyslog.d/metabase.conf
systemctl restart rsyslog
clear
echo "#-----------------------------------------#"
echo      "CRIANDO ARQUIVO DE INICIALIZACAO"
echo "#-----------------------------------------#"
cat <<EOF | sudo tee /etc/systemd/system/metabase.service
[Unit]
Description=Metabase server
After=syslog.target
After=network.target

[Service]
WorkingDirectory=/usr/share/metabase
ExecStart=/usr/bin/java -jar /usr/share/metabase/metabase.jar
EnvironmentFile=/etc/default/metabase
User=metabase
Type=simple
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=metabase
SuccessExitStatus=143
TimeoutStopSec=120
Restart=always

[Install]
WantedBy=multi-user.target
EOF
clear
echo "#-----------------------------------------#"
echo   "LIBERANDO A PORTA 3000/TCP NO FIREWALL"
echo "#-----------------------------------------#"
firewall-cmd --permanent --add-port=3000/tcp
firewall-cmd --reload 
systemctl restart firewalld
clear
echo "#-----------------------------------------#"
echo             "REINICIAR DEAMON"
echo        "INICIAR O METABASE NO BOOT"
echo        "INICIAR SERVICO DO METABASE"
echo "#-----------------------------------------#"
systemctl daemon-reload
systemctl enable metabase
systemctl start metabase
clear
echo "#-----------------------------------------#"
echo                   "FIM"
echo "#-----------------------------------------#"
echo "Acesse: http://IP-DO-SERVIDOR:3000"
echo "VEJA O LOG EM TEMPO REAL COM O COMANDO ABAIXO:"
echo "tail -f /var/log/metabase.log"
