package main;

import org.json.JSONObject;

import java.io.FileInputStream;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.Properties;
import java.util.TimeZone;

public class PasswordDB {
    public PasswordDB() { }

    public String evaluate() {
        String result = "";

        JSONObject resultSet = new JSONObject();

        try {
            result += "about to setup InputStream ";
            InputStream inputStream = new FileInputStream("/usr/local/tomcat/webapps/oracleConfig.properties");
            result += "about to create Properties object ";
            Properties properties = new Properties();
            result += "about to load properties file ";
            properties.load(inputStream);
            result += "about to get url from properties file ";
            String url = properties.getProperty("url");
            result += "about to get user from properties file ";
            String user = properties.getProperty("user");
            result += "about to get password from properties file ";
            String password = properties.getProperty("password");

            TimeZone timeZone = TimeZone.getTimeZone("America/New_York");
            TimeZone.setDefault(timeZone);
            Class.forName("oracle.jdbc.driver.OracleDriver");
            Connection conn = DriverManager.getConnection(url,user,password);
            Statement stmt = conn.createStatement();
            ResultSet rs;

            result += "about to execute query url="+url+" user="+user+" password="+password;
            rs = stmt.executeQuery("SELECT COUNTRY_ID, COUNTRY_NAME, REGION_ID FROM COUNTRIES ORDER BY REGION_ID");
            result += " back from query";
            while ( rs.next() ) {
                result += " in while loop";
                JSONObject row = new JSONObject();
                row.put("COUNTRY_ID", rs.getString("COUNTRY_ID"));
                row.put("COUNTRY_NAME", rs.getString("COUNTRY_NAME"));
                row.put("REGION_ID", rs.getString("REGION_ID"));
                resultSet.append("RESULT_SET", row);;
            }
            result += " about to close connection";
            conn.close();
            result += " connection closed";
        } catch (Exception e) {
            result += "Got an exception!";
            result += e.getMessage();
        }
        result += resultSet.toString(4);
        return result;
    }
}