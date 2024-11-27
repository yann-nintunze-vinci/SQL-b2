import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;

public class InterfaceClient {

    private Statement s;

    public InterfaceClient() {
        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            System.out.println("Driver PostgreSQL manquant");
            System.exit(1);
        }

        String url = "jdbc:postgresql://172.24.2.6:5432/dbcdamas14";
        Connection conn = null;

        try {
            conn = DriverManager.getConnection(url, "", "");
        } catch (SQLException e) {
            System.out.println("Impossible de joindre le server !");
            System.exit(1);
        }

        try {
            s = conn.createStatement();
        } catch (SQLException se) {
            System.out.println("Erreur lors de l’insertion !");
            se.printStackTrace();
            System.exit(1);
        }
    }
}
