echo "***********************************************************"
echo "*             Installing Apache HTTP Server"
echo "***********************************************************"

yum -y install httpd
  
systemctl enable httpd
systemctl start httpd
  
cp /vagrant/mod_jk.so /etc/httpd/modules/
firewall-cmd --zone=public --add-port=80/tcp --permanent