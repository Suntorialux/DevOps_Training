# To install OpenJDK 8 JDK using yum, run this command:
echo "***************************************************************"
echo "*              Installing Java"
echo "***************************************************************"

yum -y install java-1.8.0-openjdk

# To install the default Tomcat root page (tomcat-webapps), and the Tomcat Web Application Manager and Virtual Host Manager (tomcat-admin-webapps), run this command:

echo "***************************************************************"
echo "*             Installing Tomcat"
echo "***************************************************************"

yum -y install tomcat tomcat-webapps tomcat-admin-webapps
systemctl enable tomcat
systemctl start tomcat
firewall-cmd --zone=public --add-port=8009/tcp --permanent