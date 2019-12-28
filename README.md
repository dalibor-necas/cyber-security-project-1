# Cyber Security Base 2019-2020 Project I

LINK: https://github.com/dalibor-necas/cyber-security-project-1

It is recommended not to reuse this code, because the web application contains five security flaws from the [OWASP Top 10 - 2017] (https://www.owasp.org/images/7/72/OWASP_Top_10-2017_%28en%29.pdf.pdf) list. Project is done for the syber security course https://cybersecuritybase.mooc.fi/.

## Getting Started

### Users Credentials

The application has the following username and password combinations for testing:

* admin: 123456
* user: password

### Running Application

Prerequisite is that Maven 3.6 is installed.

## FLAW 1: A1:2017, Injection

### Description of flaw 1
There is an SQL injection vulnerability within the application login form. It is possible to use SQL injection attack to bypass the login.

### Steps to reproduce flaw 1
1. Open browser and go to http://localhost:8080
2. Set the username field value to: “devil' OR 1=1-- “(don’t forget the space after the --)
3. You can write any value to the password field or leave it empty
4. Click "Submit"
5. You are redirected to the super secret page and have successfully exploited the SQL injection vulnerability in the application

### How to fix flaw 1
The code in the DatabaseQueries.java class getAccount method uses raw SQL queries to check if the user exists in the database:
```
ResultSet resultSet = connection.createStatement().executeQuery("SELECT id, username, password FROM accounts WHERE username='" +username+ "' AND password='" +password+ "'");
```
Instead of the raw SQL queries, it is recommended to use prepared statements. Change the code in the DatabaseQueries.java class getAccount method as follows:
```
public Signup getAccount(String username, String password) throws SQLException {
    String query = "SELECT id, username, password FROM accounts WHERE username= ? AND password= ?";
    PreparedStatement pstmt = connection.prepareStatement(query);
    pstmt.setString(1, username);
    pstmt.setString(2, password);
    ResultSet resultSet = pstmt.executeQuery();
    while (resultSet.next()) {
        return new Signup(resultSet.getInt("id"), resultSet.getString("username"), resultSet.getString("password"));
}
```
When the application is rerun the SQL injection attack will not work anymore.
 
## FLAW 2: A3:2017, Sensitive Data Exposure

### Description of flaw 2
The application stores all user names and passwords as a clear text in the .sql file. On top of that the application does not currently support the secured protocol HTTPS, which means that anyone who has access to the network communication can eavesdrop the user credentials.

### Steps to reproduce flaw 2
1. Open browser and go to http://localhost:8080
2. Login to the application with existing credentials
3. The HTTP protocol in URL indicates that all traffic between the browser and the server goes unencrypted and does not provide sufficient protection against eavesdropping of the communication and revealing the user credentials.
4. An attacker with access to the application could also get the credentials simply by looking into the data.sql file in the project
5. All the user credentials are stored in cleartext

```
INSERT INTO accounts (id, username, password) VALUES ('1', 'admin', '123456');
INSERT INTO accounts (id, username, password) VALUES ('2', 'user', 'password');
```
 
### How to fix flaw 2
The best is to not store any unnecessary sensitive data. When it comes to necessary sensitive data, such as user credentials, they should be stored in an encrypted form. For storing passwords it is recommended to use strong adaptive and salted hashing functions with a work factor (delay factor), such as Argon2, scrypt, bcrypt, or PBKDF2. So, even in a case when the password data gets leaked, it is very likely that the attacker can’t retrieve the cleartext passwords.
The BCrypt is one of several encoding mechanisms supported by Spring Security. The password encryption with BCrypt can be implemented into the SecurityConfiguration.java class like follows:
```
public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
```
Another recommendation by OWASP is to encrypt all data in transit with secure protocols such as TLS with perfect forward secrecy (PFS) ciphers, cipher prioritization by the server, and secure parameters and enforce encryption using directives like HTTP Strict Transport Security (HSTS).

## FLAW 3: A5:2017, Broken Access Control

### Description of flaw 3
The web application does not properly enforce access control to sensitive pages. For example, anyone can access the h2-console, which can be used to gain unauthorized access into the backend database.

### Steps to reproduce flaw 3
1. Open browser and go to http://localhost:8080/h2-console

### How to fix flaw 3
It is recommended to prevent access to sensitive resources from the public Internet. This specific vulnerability can be mitigated by restricting access based on IP addresses.
We can modify the SecurityConfiguration.java class by implementing IP-restriction to the /h2-console resource as follows:
```
@Override
   protected void configure(HttpSecurity http) throws Exception {
   http.authorizeRequests()
           .antMatchers("/h2-console/*").hasIpAddress("10.0.0.0/16") //access is only allowed from IP-address 10.0.0.0/16
           .anyRequest().permitAll();
}
``` 
## FLAW 4: A6:2017, Security Misconfiguration

### Description of flaw 4
The application uses an outdated version of the Spring Framework (1.4.2). The latest stable version is 2.2.2.

### Steps to reproduce flaw 4
1. Open the pom.xml file and find the org.springframework.boot version number, which is currently 1.4.2:
```
<parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>1.4.2.RELEASE</version>
</parent>
```
### How to fix flaw 4
The issue can be fixed by modifying the org.springframework.boot version number to 2.2.2.RELEASE and then rerunning the application.
```
<parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>2.2.2.RELEASE</version>
</parent>
```
After this the application will use the latest framework version.

## FLAW 5: A9:2017, Using Components with Known Vulnerabilities

### Description of flaw 5
The application uses outdated version of the Spring Framework (1.4.2) resulting into multiple vulnerabilities and vulnerable dependencies. The latest stable version is 2.2.2.

### Steps to reproduce flaw 5
1. Open command line, run maven and navigate to the project folder
2. Analyze the project by running the command
`mvn dependency-check:check`
from the command line
3. Open the dependency-check report after the dependency-check build success. The report is located in the project target folder
4. As writing this, the dependency-check found 86 vulnerabilities and 14 vulnerable dependencies

### How to fix flaw 5
The issue can be fixed by modifying the org.springframework.boot version number to 2.2.2.RELEASE and then rerunning the application.
```
<parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>2.2.2.RELEASE</version>
</parent>
```
After this the application will use the latest framework version and the number of vulnerabilities and vulnerable dependencies is expected to decrease.
